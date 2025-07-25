
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

// TODO: Move to config or env for production
const String chatbotApiUrl = 'http://10.146.241.105:5000/chatbot';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  static const darkBlue = Color(0xFF1A237E);
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
      // Get the current locale
      final currentLocale = Localizations.localeOf(context).languageCode;
      // Map locale to language code for the API
      String langCode = 'en';
      if (currentLocale == 'hi') {
        langCode = 'hi';
      } else if (currentLocale == 'mr') {
        langCode = 'mr';
      }
      
      final response = await http.post(
        Uri.parse(chatbotApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': userMessage,
          'lang': langCode,
        }),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Schemes Chatbot',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(Icons.volume_up, color: Colors.white),
              onPressed: () => _speak("Schemes Chatbot. You can ask questions about investment schemes using voice or text."),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isUser 
                            ? LinearGradient(
                                colors: [darkBlue, darkBlue.withOpacity(0.8)],
                              )
                            : LinearGradient(
                                colors: [Colors.white, Colors.grey[50]!],
                              ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: darkBlue.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: isUser ? null : Border.all(color: darkBlue.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isUser) ...[
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: darkBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.support_agent,
                                size: 18,
                                color: darkBlue,
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                          Flexible(
                            child: Text(
                              msg['text'] ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                color: isUser ? Colors.white : Colors.black87,
                                fontFamily: 'Mulish',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (!isUser) ...[
                            SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: darkBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: GestureDetector(
                                onTap: () => _speak(msg['text'] ?? ''),
                                child: Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.volume_up,
                                    size: 16,
                                    color: darkBlue,
                                  ),
                                ),
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
          ),
          if (_isLoading) 
            Container(
              padding: EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: darkBlue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(darkBlue),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Bot is thinking...',
                      style: TextStyle(
                        color: darkBlue,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: darkBlue.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: darkBlue.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: darkBlue.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Mulish',
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask about any scheme...',
                        hintStyle: TextStyle(
                          fontFamily: 'Mulish',
                          color: Colors.grey[600],
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.chat_bubble_outline,
                          color: darkBlue.withOpacity(0.7),
                          size: 20,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: darkBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isListening ? Icons.mic : Icons.mic_none,
                                  color: isListening ? Colors.red : darkBlue,
                                  size: 18,
                                ),
                                onPressed: _listen,
                                padding: EdgeInsets.all(6),
                                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: darkBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.volume_up, color: darkBlue, size: 18),
                                onPressed: () {
                                  if (_controller.text.isNotEmpty) {
                                    _speak(_controller.text);
                                  } else {
                                    _speak("Message field is empty");
                                  }
                                },
                                padding: EdgeInsets.all(6),
                                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            ),
                          ],
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [darkBlue, darkBlue.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: darkBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: _isLoading 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _isLoading ? null : _sendMessage,
                    padding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
