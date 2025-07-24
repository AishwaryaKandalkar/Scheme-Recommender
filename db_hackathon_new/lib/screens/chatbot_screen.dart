
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

// TODO: Move to config or env for production
const String chatbotApiUrl = 'http://192.168.1.6:5000/chatbot';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
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
      _speak("Welcome to the Schemes Chatbot! You can ask questions about investment schemes using voice or text.");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    flutterTts?.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (flutterTts != null) {
      await flutterTts!.speak(text);
    }
  }

  Future<void> _listen() async {
    if (!isListening) {
      setState(() => isListening = true);
      try {
        final String result = await platform.invokeMethod('startVoiceInput');
        _controller.text = result;
      } catch (e) {
        print('Error starting speech recognition: $e');
      } finally {
        setState(() => isListening = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _isLoading = true;
      _controller.clear();
    });
    try {
      final response = await http.post(
        Uri.parse(chatbotApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': userMessage}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['answer'] ?? 'No response.';
        setState(() {
          _messages.add({'role': 'bot', 'text': botResponse});
        });
        // Automatically speak the bot response
        _speak(botResponse);
      } else {
        final errorMessage = 'Error: Could not get response from server.';
        setState(() {
          _messages.add({'role': 'bot', 'text': errorMessage});
        });
        _speak(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'Network error: $e';
      setState(() {
        _messages.add({'role': 'bot', 'text': errorMessage});
      });
      _speak(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schemes Chatbot'),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.blue),
            onPressed: () => _speak("Schemes Chatbot. You can ask questions about investment schemes using voice or text."),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(msg['text'] ?? '', style: TextStyle(fontSize: 16)),
                        ),
                        if (!isUser) ...[
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _speak(msg['text'] ?? ''),
                            child: Icon(
                              Icons.volume_up,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 8),
                Text('Bot is thinking...'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask about any scheme...',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isListening ? Icons.mic : Icons.mic_none,
                              color: isListening ? Colors.red : Colors.blue,
                            ),
                            onPressed: _listen,
                          ),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: Colors.blue),
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                _speak(_controller.text);
                              } else {
                                _speak("Message field is empty");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
