import 'package:compact_piano/l10n/all_locales.dart';
import 'package:compact_piano/l10n/local_provider.dart';
import 'package:compact_piano/screens/piano.dart';
import 'package:compact_piano/screens/classes/piano_recorder.dart';
import 'package:compact_piano/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const CompactPianoApp(),
      ),
    );

class CompactPianoApp extends StatelessWidget {
  const CompactPianoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(  // Используем Consumer для получения локали
      builder: (context, localeProvider, child) {
        return MaterialApp(
          supportedLocales: AllLocale.all, // Список поддерживаемых локалей
          locale: localeProvider.locale, // Текущая локаль
          localizationsDelegates: [
            AppLocalizations.delegate,  // Ваши локализации
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final recorder = PianoRecorder();

    return Scaffold(
      body: PageView(
        scrollDirection: Axis.vertical,
        children: [
          PianoScreen(recorder: recorder),
          const SettingsScreen(),
        ],
      ),
    );
  }
}
