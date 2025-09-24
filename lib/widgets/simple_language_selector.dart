import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../providers/app_state_provider.dart';

class SimpleLanguageSelector extends StatelessWidget {
  const SimpleLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getLanguageName(appState.currentLanguageCode),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
                onSelected: (String languageCode) {
                  _changeLanguage(context, languageCode);
                },
                itemBuilder: (BuildContext context) {
                  return LanguageService.instance.allLanguages.map((language) {
                    return PopupMenuItem<String>(
                      value: language.locale.languageCode,
                      child: Row(
                        children: [
                          Text(
                            language.flag,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            language.name,
                            style: TextStyle(
                              fontWeight: language.locale.languageCode == 
                                  appState.currentLanguageCode 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸 English';
      case 'es':
        return '🇪🇸 Español';
      case 'fr':
        return '🇫🇷 Français';
      case 'it':
        return '🇮🇹 Italiano';
      default:
        return '🇺🇸 English';
    }
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    try {
      // Direct language service call to avoid provider issues
      LanguageService.instance.setLanguage(languageCode).then((_) {
        // Force rebuild by updating the app state
        if (context.mounted) {
          final appState = Provider.of<AppStateProvider>(context, listen: false);
          appState.initialize(); // Re-initialize to sync with language service
        }
      }).catchError((error) {
        debugPrint('Language change error: $error');
        // Fallback to English
        LanguageService.instance.setLanguage('en');
      });
    } catch (e) {
      debugPrint('Language selector error: $e');
      // Fallback to English
      LanguageService.instance.setLanguage('en');
    }
  }
}
