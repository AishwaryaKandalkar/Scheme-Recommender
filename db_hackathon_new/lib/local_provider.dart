// locale_provider.dart
import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'hi', 'mr'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }
}