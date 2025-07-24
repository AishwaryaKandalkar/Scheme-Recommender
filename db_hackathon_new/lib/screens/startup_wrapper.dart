import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'language_selection_screen.dart';
import 'welcome_screen.dart';  // Update as per your structure
import 'home_screen.dart';     // Optional, in case of direct login

class StartupWrapper extends StatelessWidget {
  final bool isLoggedIn;

  const StartupWrapper({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageProvider>(context).currentLanguage;

    if (languageCode == null) {
      // Navigate to LanguageSelectionScreen with the correct target route
      return LanguageSelectionScreenWrapper(
        targetRoute: isLoggedIn ? '/home' : '/welcome',
      );
    }

    // If language already selected, show home or welcome based on login
    return isLoggedIn ? HomeScreen() : WelcomeScreen();
  }
}
class LanguageSelectionScreenWrapper extends StatelessWidget {
  final String targetRoute;

  const LanguageSelectionScreenWrapper({required this.targetRoute});

  @override
  Widget build(BuildContext context) {
    // Wrap with RouteSettings so targetRoute is passed correctly
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => LanguageSelectionScreen(),
        settings: RouteSettings(arguments: targetRoute),
      ),
    );
  }
}
