import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/location_access_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_creation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'providers/language_provider.dart';
import 'package:provider/provider.dart';

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
            supportedLocales: const [Locale('en'), Locale('hi'), Locale('ta'), Locale('te')],
            initialRoute: '/',
            routes: {
              '/': (_) => WelcomeScreen(),
              '/location': (_) => LocationAccessScreen(),
              '/language': (_) => LanguageSelectionScreen(),
              '/login': (_) => LoginScreen(),
              '/profile': (_) => ProfileCreationScreen(),
              '/home': (_) => HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
