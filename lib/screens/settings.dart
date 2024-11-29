import 'package:compact_piano/l10n/all_locales.dart';
import 'package:compact_piano/l10n/local_provider.dart';
import 'package:compact_piano/screens/classes/piano_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale;
    
    return Scaffold(
       appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.settings),  // Локализованный текст
            subtitle: DropdownButton<Locale>(
              value: currentLocale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  // Устанавливаем новый язык
                  localeProvider.setLocale(newLocale);
                }
              },
              items: AllLocale.all.map<DropdownMenuItem<Locale>>((Locale locale) {
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(locale.languageCode == 'en' ? 'English' : 'Русский'), // Можно добавить больше языков
                );
              }).toList(),
            ),
          ),
          ListTile(
            leading: Icon(PianoRecorder.isRecording ? Icons.stop : Icons.fiber_manual_record),
            title: Text(PianoRecorder.isRecording
                ? AppLocalizations.of(context)!.stopRecording
                : AppLocalizations.of(context)!.startRecording), 
            onTap: () {
              setState(() {
                PianoRecorder.toggleRecording(); // Используем widget для доступа к recorder
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.save),
             title: Text(AppLocalizations.of(context)!.exportRecording), 
            onTap: () {
              PianoRecorder.exportTrack();
            },
          ),
        ],
      ),
    );
  }
}
