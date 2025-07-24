import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/location_access_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_creation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/account_page.dart';
import 'screens/my_schemes_page.dart';
import 'screens/agent_login_screen.dart';
import 'screens/agent_register_screen.dart';
import 'providers/language_provider.dart';
import 'providers/voice_navigation_provider.dart';
import 'services/voice_navigation_service.dart';
import 'package:provider/provider.dart';
import '../gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(SchemeFinderApp());
}

class SchemeFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => VoiceNavigationProvider()),
      ],
      child: Consumer2<LanguageProvider, VoiceNavigationProvider>(
        builder: (context, langProvider, voiceProvider, _) {
          return MaterialApp(
            title: 'SchemeFinder',
            debugShowCheckedModeBanner: false,
            locale: Locale(langProvider.languageCode),
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('mr'),
            ],
            theme: ThemeData(
              // High contrast theme for better accessibility
              brightness: Brightness.light,
              primaryColor: Colors.blue.shade700,
              textTheme: TextTheme(
                bodyMedium: TextStyle(fontSize: 16.0), // Larger default text
              ),
              buttonTheme: ButtonThemeData(
                minWidth: 88.0,
                height: 48.0, // Larger touch targets
              ),
            ),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/language', // start from language screen
            builder: (context, child) {
              // Apply global accessibility features
              return MediaQuery(
                // Enable large fonts if needed
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.1, // Slightly larger text by default
                ),
                child: Semantics(
                  // Make the app more accessible
                  container: true,
                  explicitChildNodes: true,
                  child: child!,
                ),
              );
            },
            routes: {
                  '/': (_) => WelcomeScreen(),
                  '/location': (_) => LocationAccessScreen(),
                  '/language': (_) => LanguageSelectionScreen(),
                  '/login': (_) => LoginScreen(),
                  '/profile': (_) => ProfileCreationScreen(),
                  '/home': (_) => HomeScreen(),
                  '/chatbot': (_) => ChatbotScreen(),
                  '/account': (_) => AccountPage(),
                  '/edit_profile': (_) => ProfileCreationScreen(),
                  '/my_schemes': (_) => MySchemesPage(),
                  '/agent-login': (_) => AgentLoginScreen(),
                  '/agent-register': (_) => AgentRegisterScreen(),
            },
          );
        },
      ),
    );
  }
}
