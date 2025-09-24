import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

/// A widget that automatically translates text based on current language
class TranslatedText extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Map<String, String>? params;

  const TranslatedText(
    this.translationKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.params,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        String text = appState.translate(translationKey);
        
        // Replace parameters if provided
        if (params != null) {
          params!.forEach((key, value) {
            text = text.replaceAll('{$key}', value);
          });
        }
        
        return Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// A widget that automatically translates text with rich formatting
class TranslatedRichText extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Map<String, String>? params;

  const TranslatedRichText(
    this.translationKey, {
    super.key,
    this.style,
    this.textAlign,
    this.params,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        String text = appState.translate(translationKey);
        
        // Replace parameters if provided
        if (params != null) {
          params!.forEach((key, value) {
            text = text.replaceAll('{$key}', value);
          });
        }
        
        return RichText(
          textAlign: textAlign ?? TextAlign.start,
          text: TextSpan(
            text: text,
            style: style ?? DefaultTextStyle.of(context).style,
          ),
        );
      },
    );
  }
}

/// A widget that automatically translates button text
class TranslatedButton extends StatelessWidget {
  final String translationKey;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Map<String, String>? params;
  final Widget? icon;

  const TranslatedButton(
    this.translationKey, {
    super.key,
    this.onPressed,
    this.style,
    this.params,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        String text = appState.translate(translationKey);
        
        // Replace parameters if provided
        if (params != null) {
          params!.forEach((key, value) {
            text = text.replaceAll('{$key}', value);
          });
        }
        
        if (icon != null) {
          return ElevatedButton.icon(
            onPressed: onPressed,
            style: style,
            icon: icon!,
            label: Text(text),
          );
        } else {
          return ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: Text(text),
          );
        }
      },
    );
  }
}

/// A widget that automatically translates app bar title
class TranslatedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String translationKey;
  final List<Widget>? actions;
  final Widget? leading;
  final Map<String, String>? params;

  const TranslatedAppBar(
    this.translationKey, {
    super.key,
    this.actions,
    this.leading,
    this.params,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        String title = appState.translate(translationKey);
        
        // Replace parameters if provided
        if (params != null) {
          params!.forEach((key, value) {
            title = title.replaceAll('{$key}', value);
          });
        }
        
        return AppBar(
          title: Text(title),
          actions: actions,
          leading: leading,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// A widget that automatically translates floating action button
class TranslatedFloatingActionButton extends StatelessWidget {
  final String translationKey;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Map<String, String>? params;

  const TranslatedFloatingActionButton(
    this.translationKey, {
    super.key,
    this.onPressed,
    this.icon,
    this.params,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        String tooltip = appState.translate(translationKey);
        
        // Replace parameters if provided
        if (params != null) {
          params!.forEach((key, value) {
            tooltip = tooltip.replaceAll('{$key}', value);
          });
        }
        
        return FloatingActionButton(
          onPressed: onPressed,
          tooltip: tooltip,
          child: icon,
        );
      },
    );
  }
}

/// Extension to easily translate strings in any widget
extension TranslationExtension on BuildContext {
  String t(String key, {Map<String, String>? params}) {
    final appState = Provider.of<AppStateProvider>(this, listen: false);
    String text = appState.translate(key);
    
    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{$key}', value);
      });
    }
    
    return text;
  }
}
