import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

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
  }

  Future<void> stopWithFadeOut(AudioPlayer player) async {
    // if (_stopFadeOutFlags[player] == null || !_stopFadeOutFlags[player]!) return;

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
    } catch (e) {
      print("Ошибка при остановке: $e");
    } finally {
      _stopFadeOutFlags.remove(player); // Удаляем флаг
    }
  }
}