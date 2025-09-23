import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

/// App state provider for managing global app state including language
class AppStateProvider extends ChangeNotifier {
  String _currentLanguageCode = 'en';
  Locale _currentLocale = const Locale('en', 'US');
  
  String get currentLanguageCode => _currentLanguageCode;
  Locale get currentLocale => _currentLocale;
  LanguageInfo get currentLanguageInfo => LanguageService.supportedLanguages[_currentLanguageCode]!;

  /// Initialize the provider
  Future<void> initialize() async {
    await LanguageService.instance.initialize();
    _currentLanguageCode = LanguageService.instance.currentLanguageCode;
    _currentLocale = LanguageService.instance.currentLocale;
    notifyListeners();
  }

  /// Change language and notify listeners
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguageCode == languageCode) return;
    
    await LanguageService.instance.setLanguage(languageCode);
    _currentLanguageCode = languageCode;
    _currentLocale = LanguageService.instance.currentLocale;
    notifyListeners();
  }

  /// Get translation for current language
  String translate(String key) {
    return Translations.get(key, languageCode: _currentLanguageCode);
  }
}

/// Extension to easily access translations in widgets
extension AppTranslationsExtension on BuildContext {
  String t(String key) {
    return Provider.of<AppStateProvider>(this, listen: false).translate(key);
  }
}
