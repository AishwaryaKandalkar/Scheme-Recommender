import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AccountPage extends StatefulWidget {

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText speech;
  bool isListening = false;
  final TextEditingController dummyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _listen(TextEditingController controller) async {
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        setState(() => isListening = true);
        speech.listen(onResult: (result) {
          controller.text = result.recognizedWords;
        });
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Account')),
            IconButton(
              icon: Icon(Icons.volume_up, color: Colors.white),
              onPressed: () => _speak('Account'),
            ),
          ],
        ),
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
                      Navigator.pushNamed(context, '/edit_profile');
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.blueAccent),
                  onPressed: () => _speak('Edit Profile'),
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
                      Navigator.pushNamed(context, '/my_schemes');
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.blueAccent),
                  onPressed: () => _speak('My Schemes'),
                ),
              ],
            ),
            SizedBox(height: 24),
            TextFormField(
              controller: dummyController,
              decoration: InputDecoration(
                hintText: 'Say something...',
                suffixIcon: IconButton(
                  icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: Colors.blueAccent),
                  onPressed: () => _listen(dummyController),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
