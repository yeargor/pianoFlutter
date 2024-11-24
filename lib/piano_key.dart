import 'package:flutter/material.dart';
import 'audio_player_pool.dart';

enum KeyColor { WHITE, BLACK }

class PianoKey extends StatefulWidget {
  final bool isWhiteKey;
  final String note;
  final AudioPlayerPool audioPlayerPool;
  final Function(String notePath) onKeyPressed;

  const PianoKey({
    super.key,
    required this.isWhiteKey,
    required this.note,
    required this.audioPlayerPool,
    required this.onKeyPressed,
  });

  @override
  _PianoKeyState createState() => _PianoKeyState();
}

class _PianoKeyState extends State<PianoKey> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final notePath = "notes/${widget.note}.wav";
        widget.audioPlayerPool.play(notePath);
        widget.onKeyPressed(notePath);
      },
      child: Container(
        width: 50,
        height: widget.isWhiteKey ? 150 : 100,
        color: widget.isWhiteKey ? Colors.white : Colors.black,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.bottomCenter,
        child: Text(
          widget.note,
          style: TextStyle(
            color: widget.isWhiteKey ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
