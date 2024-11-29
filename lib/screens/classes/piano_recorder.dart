  import 'dart:io';
  import 'package:compact_piano/screens/classes/note_recorded.dart';
  import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
  import 'package:flutter/services.dart';
  import 'package:path_provider/path_provider.dart';

  class PianoRecorder {
    static bool isRecording = false;

    // Метод для начала или остановки записи
    static void toggleRecording() {
      isRecording = !isRecording;
      if (isRecording) {
        // Очищаем список записанных нот при начале новой записи
        RecordedNoteStorage.clear();
        RecordedNoteStorage.startTime = DateTime.now().millisecondsSinceEpoch;
        print("Запись началась");
      } else {
        // Устанавливаем конечное время записи
        RecordedNoteStorage.endTime = DateTime.now().millisecondsSinceEpoch;
        print("Запись остановлена");
      }
    }

    static Future<void> exportTrack() async {
      List<RecordedNote> notes = RecordedNoteStorage.recordedNotes;
      String outputFilePath = "/storage/emulated/0/Download/recorded_piano.wav";
      File outputFile = File(outputFilePath);

      if (notes.isEmpty) {
        print("No notes to export.");
        return;
      }

      // Извлекаем файлы из assets в физическую директорию
      List<String> extractedPaths = [];
      for (var note in notes) {
        String extractedPath = await extractAsset(note.filePath);
        extractedPaths.add(extractedPath);
      }

      // Строим фильтры для FFmpeg
      String filterComplex = _buildFilterComplex(notes);
      String inputFiles = _buildInputFiles(extractedPaths);

      String command = '-y $inputFiles -filter_complex "$filterComplex" -map "[out]" -vn -ar 44100 -ac 2 $outputFilePath';

      print("Executing command: $command");

      // Выполняем команду ffmpeg
      FFmpegKit.execute(command).then((session) {
        session.getReturnCode().then((returnCode) {
          if (returnCode!.isValueSuccess()) {
            print("Track exported successfully to $outputFilePath");
            RecordedNoteStorage.clear();
          } else {
            session.getLogs().then((logs) {
              for (var log in logs) {
                print("FFmpeg Log: ${log.getMessage()}");
              }
            });
            print("Error occurred during export: $returnCode");
          }
        });
      });
    }

    static String _buildInputFiles(List<String> extractedPaths) {
      String inputFiles = "";
      for (int i = 0; i < extractedPaths.length; i++) {
        inputFiles += "-i ${extractedPaths[i]} ";
      }
      return inputFiles;
    }

    static String _buildFilterComplex(List<RecordedNote> notes) {
      List<String> filters = [];

      // Для каждой ноты создаем фильтр
      for (int i = 0; i < notes.length; i++) {
        RecordedNote note = notes[i];

        // Рассчитываем время начала ноты относительно начала трека
        int notePlayTime = (note.timeStarted ?? 0) - (RecordedNoteStorage.startTime ?? 0);

        // Формируем фильтр для каждой ноты, с учётом длительности
        filters.add(
          "[$i:a]adelay=$notePlayTime|$notePlayTime,atrim=end=${notePlayTime+note.duration}[a$i]"
        );
      }

      // Соединяем все фильтры и добавляем amix для смешивания всех треков
      String filterComplex = "${filters.join("; ")}; [${List.generate(notes.length, (index) => "a$index").join("][")}]amix=inputs=${notes.length}[out]";

      return filterComplex;
    }




    // Извлекаем файл из assets в файловую систему
    static Future<String> extractAsset(String assetPath) async {
      // Получаем путь к временной директории приложения
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${assetPath.split('/').last}';
      final file = File(filePath);

      if (!file.existsSync()) {
        // Загружаем файл из assets в файловую систему
        final byteData = await rootBundle.load(assetPath);
        final bytes = byteData.buffer.asUint8List();
        await file.writeAsBytes(bytes);
        print("File extracted to: $filePath");
      }

      return filePath;  // Возвращаем путь к извлеченному файлу
    }
  }
