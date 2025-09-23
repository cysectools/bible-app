import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../providers/app_state_provider.dart';

/// Language selector widget with flag dropdown
class LanguageSelector extends StatelessWidget {
  final bool showLabel;
  final EdgeInsetsGeometry? padding;

  const LanguageSelector({
    super.key,
    this.showLabel = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final currentLanguage = appState.currentLanguageInfo;
    
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel) ...[
            Text(
              Translations.get(AppTranslations.language),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
          ],
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentLanguage.flag,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    currentLanguage.nativeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
            ),
            onSelected: (String languageCode) async {
              final appState = Provider.of<AppStateProvider>(context, listen: false);
              await appState.setLanguage(languageCode);
            },
            itemBuilder: (BuildContext context) {
              final appState = Provider.of<AppStateProvider>(context);
              return LanguageService.instance.allLanguages.map((language) {
                final isSelected = language.locale.languageCode == 
                    appState.currentLanguageCode;
                
                return PopupMenuItem<String>(
                  value: language.locale.languageCode,
                  child: Row(
                    children: [
                      Text(
                        language.flag,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              language.nativeName,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Theme.of(context).primaryColor : null,
                              ),
                            ),
                            Text(
                              language.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: Theme.of(context).primaryColor,
                          size: 20,
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
  }
}

/// Compact language selector for app bars
class CompactLanguageSelector extends StatelessWidget {
  const CompactLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final currentLanguage = appState.currentLanguageInfo;
    
    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentLanguage.flag,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_drop_down,
            color: Colors.white70,
            size: 16,
          ),
        ],
      ),
      onSelected: (String languageCode) async {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        await appState.setLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) {
        final appState = Provider.of<AppStateProvider>(context);
        return LanguageService.instance.allLanguages.map((language) {
          final isSelected = language.locale.languageCode == 
              appState.currentLanguageCode;
          
          return PopupMenuItem<String>(
            value: language.locale.languageCode,
            child: Row(
              children: [
                Text(
                  language.flag,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    language.nativeName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
