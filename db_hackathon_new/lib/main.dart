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
import 'package:provider/provider.dart';
import '../gen_l10n/app_localizations.dart';
import 'screens/support_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(SchemeFinderApp());
}

class SchemeFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, _) {
          return MaterialApp(
            title: 'SchemeFinder',
            debugShowCheckedModeBanner: false,
            locale: Locale(langProvider.languageCode),
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('mr'),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/language', // start from language screen
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
                  '/support': (context) => SupportPage(),
            },
          );
        },
      ),
    );
  }
}
