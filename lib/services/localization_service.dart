import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _localeKey = 'selected_locale';
  
  Locale _locale = const Locale('tr', 'TR');
  Locale get locale => _locale;

  bool get isTurkish => _locale.languageCode == 'tr';
  bool get isEnglish => _locale.languageCode == 'en';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null) {
      switch (savedLocale) {
        case 'tr':
          _locale = const Locale('tr', 'TR');
          break;
        case 'en':
          _locale = const Locale('en', 'US');
          break;
        default:
          _locale = const Locale('tr', 'TR');
      }
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'tr' 
        ? const Locale('en', 'US')
        : const Locale('tr', 'TR');
    await setLocale(newLocale);
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'Türkçe';
    }
  }
}