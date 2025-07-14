import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Hindi', 'Tamil', 'Telugu'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/welcome_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Language selector
          Positioned(
            top: 40,
            right: 16,
            child: DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: Colors.white,
              icon: Icon(Icons.language, color: Colors.white),
              underline: SizedBox(),
              onChanged: (val) => setState(() => _selectedLanguage = val!),
              items: _languages.map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang),
              )).toList(),
            ),
          ),
          // Buttons
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to SchemeFinder',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        backgroundColor: Colors.greenAccent.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text('Register', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
