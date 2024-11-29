import 'package:compact_piano/screens/classes/audio_player_pool.dart';
import 'package:compact_piano/screens/classes/piano_key.dart';
import 'package:compact_piano/screens/classes/piano_recorder.dart';
import 'package:flutter/material.dart';

class PianoScreen extends StatefulWidget {
  const PianoScreen({super.key, required this.recorder});
  final PianoRecorder recorder;

  @override
  _PianoScreenState createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  final AudioPlayerPool audioPlayerPool = AudioPlayerPool();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final whiteKeySize = constraints.maxWidth / 7;
        final blackKeySize = whiteKeySize / 2;

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            body: Stack(
              children: [
                _buildWhiteKeys(whiteKeySize, audioPlayerPool),
                _buildBlackKeys(constraints.maxHeight, blackKeySize, whiteKeySize, audioPlayerPool),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildWhiteKeys(double whiteKeySize, AudioPlayerPool audioPlayerPool) {
    return Row(
      children: [
        PianoKey.white(
          width: whiteKeySize,
          note: 'C',  
          audioPlayerPool: audioPlayerPool,
        ),
        PianoKey.white(
          width: whiteKeySize,
          note: 'D',
          audioPlayerPool: audioPlayerPool,
        ),
        PianoKey.white(
          width: whiteKeySize,
          note: 'E',
          audioPlayerPool: audioPlayerPool,
        ),
        PianoKey.white(
          width: whiteKeySize,
          note: 'F',
          audioPlayerPool: audioPlayerPool,
        ),
        PianoKey.white(
          width: whiteKeySize,
          note: 'G',
          audioPlayerPool: audioPlayerPool,
        ),
        PianoKey.white(
          width: whiteKeySize,
          note: 'A',
          audioPlayerPool: audioPlayerPool,
        ),
        PianoKey.white(
          width: whiteKeySize,
          note: 'B',
          audioPlayerPool: audioPlayerPool,
        ),
      ],
    );
  }

  _buildBlackKeys(double pianoHeight, double blackKeySize, double whiteKeySize, AudioPlayerPool audioPlayerPool) {
    return SizedBox(
      height: pianoHeight * 0.55,
      child: Row(
        children: [
          SizedBox(
            width: whiteKeySize - blackKeySize / 2,
          ),
          PianoKey.black(
            width: blackKeySize,
            note: 'C#',
            audioPlayerPool: audioPlayerPool,
          ),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
            width: blackKeySize,
            note: 'D#',
            audioPlayerPool: audioPlayerPool,
          ),
          SizedBox(
            width: whiteKeySize,
          ),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
            width: blackKeySize,
            note: 'F#',
            audioPlayerPool: audioPlayerPool,
          ),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
            width: blackKeySize,
            note: 'G#',
            audioPlayerPool: audioPlayerPool,
          ),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
            width: blackKeySize,
            note: 'A#',
            audioPlayerPool: audioPlayerPool,
          ),
        ],
      ),
    );
  }
}
