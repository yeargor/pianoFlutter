import 'package:audioplayers/audioplayers.dart';

class AudioPlayerPool {
  final List<AudioPlayer> _players = [];

  AudioPlayer getAvailablePlayer() {
    for (var player in _players) {
      if (player.state == PlayerState.stopped || player.state == PlayerState.completed) {
        return player;
      }
    }
    // Если нет свободных игроков, создаём новый
    final newPlayer = AudioPlayer();
    _players.add(newPlayer);
    return newPlayer;
  }

  Future<void> play(String filePath) async {
    final player = getAvailablePlayer();
    await player.play(AssetSource(filePath)); // Используйте AssetSource для файлов в папке assets
  }
}
