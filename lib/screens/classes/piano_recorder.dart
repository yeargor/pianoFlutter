import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class PianoRecorder {
  static bool isRecording = false;
  List<String> recordedNotes = [];
  final String outputPath = "\\storage\\emulated\\0\\Download\\recorded_piano.wav";

  void toggleRecording() {
    isRecording = !isRecording;
    if (isRecording) {
      recordedNotes.clear();
      print("Запись началась");
    } else {
      print("Запись остановлена");
    }
  }

  Future<String> copyAssetToTemporaryDirectory(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    print("Ассет скопирован: ${tempFile.path}");
    return tempFile.path;
  }

  void recordNote(String notePath) {
    if (isRecording) {
      final assetPath = "assets/$notePath";
      recordedNotes.add(assetPath);
      print("Нота записана: $assetPath");
    }
  }

  void createFile(String path) {
    final file = File(path);
    final directory = file.parent;

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print('Директория создана: ${directory.path}');
    }

    print('Файл будет записан по пути: ${file.path}');
  }

  Future<void> requestPermissions() async {
    PermissionStatus status = await Permission.storage.request();
    if (!await Permission.storage.request().isGranted || !await Permission.manageExternalStorage.request().isGranted) {
      print('Доступ к хранилищу не предоставлен.');
    }
    if (status.isPermanentlyDenied) {
      print("Доступ к хранилищу постоянно запрещен.");
      await openAppSettings();
      return;
    }
  }

  Future<void> exportRecording() async {
    if (recordedNotes.isEmpty) {
      print("Нет записанных нот для экспорта");
      return;
    }
    createFile(outputPath);

    print("Экспорт начинается...");
    await requestPermissions();
    await mergeAudioFiles(recordedNotes, outputPath);
  }

  Future<void> mergeAudioFiles(List<String> assetPaths, String outputPath) async {
    print("[FFmpeg] Начало обработки ассетов...");

    List<String> tempFiles = [];
    for (String asset in assetPaths) {
      try {
        final tempFile = await copyAssetToTemporaryDirectory(asset);
        tempFiles.add(tempFile);
      } catch (e) {
        print("[FFmpeg] Ошибка при извлечении ассета $asset: $e");
        return;
      }
    }

    print("[FFmpeg] Все ассеты извлечены. Начало слияния аудиофайлов...");

    final sanitizedOutputPath = outputPath.replaceAll("\\", "/");

    final outputFile = File(sanitizedOutputPath);
    if (outputFile.existsSync()) {
      try {
        await outputFile.delete();
        print("[FFmpeg] Существующий файл удалён: $sanitizedOutputPath");
      } catch (e) {
        print("[FFmpeg] Не удалось удалить существующий файл: $e");
        return;
      }
    }

    String inputList = tempFiles.map((file) => "-i $file").join(" ");
    String filterComplex = "${List.generate(tempFiles.length, (i) => "[$i:0]").join("")}concat=n=${tempFiles.length}:v=0:a=1[out]";
    String command = "$inputList -filter_complex \"$filterComplex\" -map \"[out]\" \"$sanitizedOutputPath\"";

    print("[FFmpeg] Команда для выполнения: $command");

    await FFmpegKit.executeAsync(command, (session) async {
      final returnCode = await session.getReturnCode();
      if (returnCode != null && returnCode.isValueSuccess()) {
        print("[FFmpeg] Экспорт успешен. Файл сохранён: $sanitizedOutputPath");
      } else {
        print("[FFmpeg] Ошибка экспорта.");
      }
    });
  }
}
