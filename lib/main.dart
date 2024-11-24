import 'package:flutter/material.dart';
import 'audio_player_pool.dart';
import 'piano_key.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const CompactPianoApp());

class CompactPianoApp extends StatelessWidget {
  const CompactPianoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PianoScreen(),
    );
  }
}

class PianoScreen extends StatefulWidget {
  const PianoScreen({super.key});

  @override
  _PianoScreenState createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  final AudioPlayerPool audioPlayerPool = AudioPlayerPool();
  bool isRecording = false;
  List<String> recordedNotes = [];
  final String outputPath = "\\storage\\emulated\\0\\Download\\recorded_piano.wav";

  void toggleRecording() {
    setState(() {
      isRecording = !isRecording;
    });

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

    // Убедитесь, что директория существует
    if (!directory.existsSync()) {
      directory.createSync(recursive: true); // Создание вложенных директорий, если нужно
      print('Директория создана: ${directory.path}');
    }
    
    print('Файл будет записан по пути: ${file.path}');
  }



  Future<void> requestPermissions() async {
    PermissionStatus status = await Permission.storage.request();
    if (!await Permission.storage.request().isGranted || !await Permission.manageExternalStorage.request().isGranted) {
      print('Доступ к хранилищу не предоставлен.'); }
    if (status.isPermanentlyDenied) {
      print("Доступ к хранилищу постоянно запрещен. Перейдите в настройки, чтобы включить его.");
      // Можно открыть настройки приложения
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
    requestPermissions();
    await mergeAudioFiles(recordedNotes, outputPath);
  }

  Future<void> mergeAudioFiles(List<String> assetPaths, String outputPath) async {
    print("[FFmpeg] Начало обработки ассетов...");

    // Извлечение ассетов во временную папку
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

    // Пример команды FFmpeg
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

    // Выполнение команды
    await FFmpegKit.executeAsync(command, (session) async {
      final returnCode = await session.getReturnCode();
      if (returnCode != null && returnCode.isValueSuccess()) {
        print("[FFmpeg] Экспорт успешен. Файл сохранён: $sanitizedOutputPath");
      } else {
        print("[FFmpeg] Ошибка экспорта.");
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compact Piano')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: toggleRecording,
                child: Text(isRecording ? "Остановить запись" : "Начать запись"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: exportRecording,
                child: const Text("Экспортировать запись"),
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PianoKey(
                  isWhiteKey: true,
                  note: 'A',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
                PianoKey(
                  isWhiteKey: false,
                  note: 'A#',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
                PianoKey(
                  isWhiteKey: true,
                  note: 'B',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
                PianoKey(
                  isWhiteKey: true,
                  note: 'C',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
                PianoKey(
                  isWhiteKey: false,
                  note: 'C#',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
                PianoKey(
                  isWhiteKey: true,
                  note: 'D',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
                PianoKey(
                  isWhiteKey: false,
                  note: 'D#',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
                PianoKey(
                  isWhiteKey: true,
                  note: 'E',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
                PianoKey(
                  isWhiteKey: true,
                  note: 'F',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
                PianoKey(
                  isWhiteKey: false,
                  note: 'F#',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
                PianoKey(
                  isWhiteKey: true,
                  note: 'G',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
                PianoKey(
                  isWhiteKey: false,
                  note: 'G#',
                  audioPlayerPool: audioPlayerPool,
                  onKeyPressed: (notePath) => recordNote(notePath),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
