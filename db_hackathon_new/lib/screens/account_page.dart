import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  FlutterTts? flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("Account page. You can edit your profile or view your saved schemes.");
    });
  }

  @override
  void dispose() {
    flutterTts?.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (flutterTts != null) {
      await flutterTts!.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.pinkAccent),
            onPressed: () => _speak("Account page. You can edit your profile or view your saved schemes."),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text('Edit Profile'),
                    onPressed: () {
                      _speak("Edit Profile");
                      Navigator.pushNamed(context, '/edit_profile');
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.pinkAccent),
                  onPressed: () => _speak("Edit Profile. Tap to modify your personal information and preferences."),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.list_alt),
                    label: Text('My Schemes'),
                    onPressed: () {
                      _speak("My Schemes");
                      Navigator.pushNamed(context, '/my_schemes');
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.pinkAccent),
                  onPressed: () => _speak("My Schemes. View your saved and bookmarked investment schemes."),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
