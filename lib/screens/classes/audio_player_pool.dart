import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:compact_piano/screens/classes/note_recorded.dart';
import 'package:compact_piano/screens/classes/piano_recorder.dart';

class AudioPlayerPool {
  //final List<AudioPlayer> _players = [];
  final Map<AudioPlayer, bool> _stopFadeOutFlags = {};
  final Map<String, AudioPlayer> _noteToPlayer = {};
  
  // Возвращает доступный плеер или создаёт новый
  AudioPlayer getAvailablePlayer(String filePath) {
    if (_noteToPlayer.containsKey(filePath)) {
      final player = _noteToPlayer[filePath]!;
      return player;
    }
    final newPlayer = AudioPlayer();
    //_players.add(newPlayer);
    _noteToPlayer[filePath] = newPlayer;
    return newPlayer;
  }

  Future<void> play(String filePath, AudioPlayer player) async { // Устанавливаем флаг
    if (player.state == PlayerState.playing) {
      _stopFadeOutFlags[player] = true;
      await player.stop();
    }
    await player.setVolume(1.0);
    await player.play(AssetSource(filePath));

    if(PianoRecorder.isRecording){
      RecordedNote note = RecordedNote.empty();
      note.setFilePath(filePath);
      note.setTimeStarted(DateTime.now().millisecondsSinceEpoch);
      RecordedNoteStorage.addNote(note);
    }
  }

  Future<void> stopWithFadeOut(String notePath) async {
    // if (_stopFadeOutFlags[player] == null || !_stopFadeOutFlags[player]!) return;
    final player = getAvailablePlayer(notePath);

    _stopFadeOutFlags[player] = false; // Устанавливаем, что начинается фейд-аут
    double currentVolume = 1.0;
    const fadeOutDuration = Duration(milliseconds: 500);
    const fadeOutSteps = 10;
    final fadeStep = 1.0 / fadeOutSteps;

    try {
      for (int i = 0; i < fadeOutSteps; i++) {
        if (_stopFadeOutFlags[player] == true) return; // Прерываем фейд-аут
        currentVolume -= fadeStep;
        currentVolume = currentVolume.clamp(0.0, 1.0);
        await player.setVolume(currentVolume);
        await Future.delayed(fadeOutDuration ~/ fadeOutSteps);
      }
      await player.stop();

      if(PianoRecorder.isRecording){
        RecordedNote? foundNote = RecordedNoteStorage.recordedNotes.firstWhere(
          (note) => note.filePath == notePath && note.timeEnded == 0,
          orElse: () => RecordedNote.empty(),
        );
        if (foundNote.filePath.isNotEmpty) {
          foundNote.setTimeEnded(DateTime.now().millisecondsSinceEpoch);
        }
      }
    } catch (e) {
      print("Ошибка при остановке: $e");
    } finally {
      _stopFadeOutFlags.remove(player);
    }
  }
}