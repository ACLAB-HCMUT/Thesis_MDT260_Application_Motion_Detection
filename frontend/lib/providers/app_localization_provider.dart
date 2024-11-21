import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart'; // Đảm bảo đường dẫn đúng với vị trí của app_localizations.dart

class AppLocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }
}
