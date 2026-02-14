import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static final LanguageService _instance = LanguageService._internal();

  factory LanguageService() => _instance;
  LanguageService._internal();

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  final Map<String, Map<String, String>> _languages = {
    'en': {'name': 'English', 'nativeName': 'English'},
    'ar': {'name': 'Arabic', 'nativeName': 'العربية'},
    'ur': {'name': 'Urdu', 'nativeName': 'اردو'},
    'id': {'name': 'Bahasa Indonesia', 'nativeName': 'Bahasa Indonesia'},
    'de': {'name': 'German', 'nativeName': 'Deutsch'},
  };

  Map<String, Map<String, String>> get languages => _languages;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null && _languages.containsKey(savedLanguage)) {
      _currentLocale = Locale(savedLanguage);
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_languages.containsKey(languageCode)) {
      _currentLocale = Locale(languageCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }

  String getLanguageName(String code) {
    return _languages[code]?['name'] ?? code;
  }

  String getNativeLanguageName(String code) {
    return _languages[code]?['nativeName'] ?? code;
  }

  bool isRtl() {
    return ['ar', 'ur'].contains(_currentLocale.languageCode);
  }
}
