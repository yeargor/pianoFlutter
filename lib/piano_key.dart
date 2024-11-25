import 'package:flutter/material.dart';
import 'audio_player_pool.dart';

enum KeyColor { WHITE, BLACK }

class PianoKey extends StatelessWidget {
  final KeyColor color;
  final double width;
  final String note;
  final AudioPlayerPool audioPlayerPool;
  final Function(String notePath) onKeyPressed;

  const PianoKey.white({
    super.key,
    required this.width,
    required this.note,
    required this.audioPlayerPool,
    required this.onKeyPressed,
  }) : color = KeyColor.WHITE;

  const PianoKey.black({
    super.key,
    required this.width,
    required this.note,
    required this.audioPlayerPool,
    required this.onKeyPressed,
  }) : color = KeyColor.BLACK;

  @override
  Widget build(BuildContext context) {
    Future<void> handleTapDown() async {
      final notePath = "notes/$note.wav";
      final player = audioPlayerPool.getAvailablePlayer(notePath); // Получаем плеер
      await audioPlayerPool.play(notePath, player); // Передаём плеер в метод play
      onKeyPressed(notePath);
    }

    Future<void> handleTapUp() async {
      final notePath = "notes/$note.wav";
      final player = audioPlayerPool.getAvailablePlayer(notePath); // Получаем тот же плеер
      await audioPlayerPool.stopWithFadeOut(player); // Передаём плеер в метод stopWithFadeOut
    }

    return GestureDetector(
      onTapDown: (_) => handleTapDown(),
      onTapUp: (_) => handleTapUp(),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: color == KeyColor.WHITE ? Colors.white : Colors.black,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
      ),
    );
  }
}
