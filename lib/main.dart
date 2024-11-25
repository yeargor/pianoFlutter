import 'package:compact_piano/screens/piano.dart';
import 'package:compact_piano/screens/classes/piano_recorder.dart';
import 'package:compact_piano/screens/settings.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CompactPianoApp());

class CompactPianoApp extends StatelessWidget {
  const CompactPianoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    final recorder = PianoRecorder();
    
    return Scaffold(
      body: PageView(
        scrollDirection: Axis.vertical,
        children: [
          PianoScreen(recorder: recorder),
          SettingsScreen(recorder: recorder),
        ],
      ),
    );
  }
}
