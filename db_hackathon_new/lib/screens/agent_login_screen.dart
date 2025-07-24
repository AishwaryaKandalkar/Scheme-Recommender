import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class AgentLoginScreen extends StatefulWidget {
  @override
  _AgentLoginScreenState createState() => _AgentLoginScreenState();
}

class _AgentLoginScreenState extends State<AgentLoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Voice feature fields
  FlutterTts? flutterTts;
  bool isListening = false;
  static const platform = MethodChannel('voice_channel');

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("Agent Login screen. Please enter your Agent ID and password to continue.");
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    flutterTts?.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (flutterTts != null) {
      await flutterTts!.speak(text);
    }
  }

  Future<void> _listen(TextEditingController controller) async {
    if (!isListening) {
      setState(() => isListening = true);
      try {
        final String result = await platform.invokeMethod('startVoiceInput');
        controller.text = result;
      } catch (e) {
        print('Error starting speech recognition: $e');
      } finally {
        setState(() => isListening = false);
      }
    }
  }

  void _login() async {
    setState(() => _isLoading = true);
    // TODO: Implement agent login logic (API call)
    await Future.delayed(Duration(seconds: 1));
    setState(() => _isLoading = false);
    
    _speak("Agent login successful! Redirecting to home screen.");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agent login successful!')),
    );
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agent Login'),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.orange),
            onPressed: () => _speak("Agent Login screen. Please enter your Agent ID and password to continue."),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 60, color: Colors.orange),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Agent Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: Colors.orange, size: 20),
                      onPressed: () => _speak("Agent Login"),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'Agent ID',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            color: isListening ? Colors.red : Colors.orange,
                          ),
                          onPressed: () => _listen(_idController),
                        ),
                        IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.orange),
                          onPressed: () {
                            if (_idController.text.isNotEmpty) {
                              _speak("Agent ID: ${_idController.text}");
                            } else {
                              _speak("Agent ID field is empty");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            color: isListening ? Colors.red : Colors.orange,
                          ),
                          onPressed: () => _listen(_passwordController),
                        ),
                        IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.orange),
                          onPressed: () {
                            if (_passwordController.text.isNotEmpty) {
                              _speak("Password entered");
                            } else {
                              _speak("Password field is empty");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    _speak("Logging in");
                    _login();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 45),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
