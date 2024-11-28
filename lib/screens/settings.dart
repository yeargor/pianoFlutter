import 'package:compact_piano/screens/classes/piano_recorder.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final PianoRecorder recorder;

  const SettingsScreen({super.key, required this.recorder});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Настройки")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            leading: Icon(PianoRecorder.isRecording ? Icons.stop : Icons.fiber_manual_record),
            title: Text(PianoRecorder.isRecording ? "Остановить запись" : "Начать запись"),
            onTap: () {
              setState(() {
                widget.recorder.toggleRecording(); // Используем widget для доступа к recorder
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text("Экспортировать запись"),
            onTap: () {
              widget.recorder.exportRecording();
            },
          ),
        ],
      ),
    );
  }
}
