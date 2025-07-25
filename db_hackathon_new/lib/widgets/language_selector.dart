import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../gen_l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsAppBarAction;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const LanguageSelector({
    Key? key,
    this.showAsAppBarAction = true,
    this.icon,
    this.iconColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (showAsAppBarAction) {
      return PopupMenuButton<String>(
        icon: Icon(
          icon ?? Icons.translate,
          color: iconColor ?? Colors.white,
        ),
        onSelected: (String languageCode) {
          languageProvider.setLanguage(languageCode);
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'en',
            child: Row(
              children: [
                Text('🇺🇸'),
                SizedBox(width: 8),
                Text('English'),
                if (languageProvider.languageCode == 'en') ...[
                  Spacer(),
                  Icon(Icons.check, color: Colors.green),
                ],
              ],
            ),
          ),
          PopupMenuItem(
            value: 'hi',
            child: Row(
              children: [
                Text('🇮🇳'),
                SizedBox(width: 8),
                Text('हिंदी'),
                if (languageProvider.languageCode == 'hi') ...[
                  Spacer(),
                  Icon(Icons.check, color: Colors.green),
                ],
              ],
            ),
          ),
          PopupMenuItem(
            value: 'mr',
            child: Row(
              children: [
                Text('🇮🇳'),
                SizedBox(width: 8),
                Text('मराठी'),
                if (languageProvider.languageCode == 'mr') ...[
                  Spacer(),
                  Icon(Icons.check, color: Colors.green),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: languageProvider.languageCode,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 16),
          onChanged: (String? newValue) {
            if (newValue != null) {
              languageProvider.setLanguage(newValue);
            }
          },
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇺🇸'),
                  SizedBox(width: 4),
                  Text('EN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'hi',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇮🇳'),
                  SizedBox(width: 4),
                  Text('हि', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'mr',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇮🇳'),
                  SizedBox(width: 4),
                  Text('मर', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageSelectorFloating extends StatelessWidget {
  final VoidCallback? onLanguageChanged;

  const LanguageSelectorFloating({
    Key? key,
    this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: LanguageSelector(
            showAsAppBarAction: false,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
