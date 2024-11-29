import 'package:flutter/material.dart';
import 'package:compact_piano/l10n/all_locales.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = AllLocale.all[1];  // Устанавливаем английский как начальную локаль

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!AllLocale.all.contains(locale)) return;
    _locale = locale;
    notifyListeners(); // Уведомляем об изменении локали
  }
}
