
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import '../services/voice_navigation_service.dart';
import '../widgets/voice_navigation_widget.dart';
import '../widgets/accessible_widgets.dart';

// TODO: Move to config or env for production
const String chatbotApiUrl = 'http://10.166.220.251:5000/chatbot';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  
  // Animation controller for the microphone button
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Voice navigation service
  final VoiceNavigationService _voiceService = VoiceNavigationService();
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _voiceService.init();
    
    // Initialize animation controller for mic button
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticInOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("Welcome to the Schemes Chatbot! You can ask questions about investment schemes using voice or text. Tap the microphone to speak, or use the text field at the bottom.");
      
      // Register navigation commands
      _voiceService.registerNavigationCommand('send message', () => _sendMessage());
      _voiceService.registerNavigationCommand('clear messages', () => _clearMessages());
      _voiceService.registerNavigationCommand('read last message', () => _readLastMessage());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _voiceService.stopSpeaking();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _voiceService.speak(text);
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
    _speak("Messages cleared");
  }
  
  void _readLastMessage() {
    if (_messages.isNotEmpty) {
      final lastMsg = _messages.last;
      _speak(lastMsg['role'] == 'bot' ? "Bot said: ${lastMsg['text']}" : "You said: ${lastMsg['text']}");
    } else {
      _speak("No messages yet");
    }
  }

  Future<void> _listen() async {
    if (!isListening) {
      setState(() => isListening = true);
      _animationController.repeat(reverse: true);
      
      try {
        final result = await _voiceService.listen(
          context: context,
          prompt: "What would you like to ask about schemes?",
        );
        
        if (result != null && result.isNotEmpty) {
          _controller.text = result;
          
          // If it's a command, process it
          if (result.toLowerCase().contains('send') && _controller.text.isNotEmpty) {
            _sendMessage();
          }
        }
      } catch (e) {
        print('Error starting speech recognition: $e');
        _speak("I couldn't hear that. Please try again.");
      } finally {
        _animationController.stop();
        _animationController.reset();
        setState(() => isListening = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) {
      _speak("Please enter a message or use voice input first");
      return;
    }
    
    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _isLoading = true;
      _controller.clear();
    });
    
    // Scroll to the bottom of the chat
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    try {
      // Provide audio feedback that message is sending
      _speak("Sending message");
      
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
        
        // Scroll to the bottom again after response
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        
        // Automatically speak the bot response
        _speak("Bot says: $botResponse");
      } else {
        final errorMessage = 'Error: Could not get response from server.';
        setState(() {
          _messages.add({'role': 'bot', 'text': errorMessage});
        });
        _speak("Error: $errorMessage");
      }
    } catch (e) {
      final errorMessage = 'Network error: $e';
      setState(() {
        _messages.add({'role': 'bot', 'text': errorMessage});
      });
      _speak("Network error occurred. Please check your connection and try again.");
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
          // Voice help button
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            tooltip: 'Voice Navigation Help',
            onPressed: () => _voiceService.provideHelp(),
          ),
          // Read instructions button
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.white),
            tooltip: 'Read Instructions',
            onPressed: () => _speak("Schemes Chatbot. You can ask questions about investment schemes using voice or text. Tap the microphone button to speak, or use the text field at the bottom. Say 'help' anytime for assistance."),
          ),
          // Toggle voice navigation
          IconButton(
            icon: Icon(_voiceService.isVoiceEnabled ? Icons.mic : Icons.mic_off, 
                      color: _voiceService.isVoiceEnabled ? Colors.white : Colors.grey),
            tooltip: 'Toggle Voice Navigation',
            onPressed: () async {
              await _voiceService.toggleVoiceNavigation();
              setState(() {});
              _speak(_voiceService.isVoiceEnabled ? "Voice navigation enabled" : "Voice navigation disabled");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                
                // Enhanced for accessibility - make each message focusable and readable
                return Semantics(
                  label: isUser ? "Your message" : "Bot message",
                  value: msg['text'] ?? '',
                  button: true,
                  excludeSemantics: true,
                  onTap: () => _speak(isUser ? "Your message: ${msg['text']}" : "Bot says: ${msg['text']}"),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUser ? Colors.blue.shade300 : Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Message sender indicator for screen readers
                          Text(
                            isUser ? 'You' : 'Bot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isUser ? Colors.blue.shade700 : Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 4),
                          // Message text
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(msg['text'] ?? '', 
                                  style: TextStyle(fontSize: 16)),
                              ),
                              SizedBox(width: 8),
                              // Always show speak button for better accessibility
                              GestureDetector(
                                onTap: () => _speak(isUser ? "Your message: ${msg['text']}" : "Bot says: ${msg['text']}"),
                                child: Icon(
                                  Icons.volume_up,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) 
            Semantics(
              label: "Bot is thinking",
              excludeSemantics: true,
              child: Padding(
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
            ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                // Voice commands suggestions
                Semantics(
                  label: "Voice command suggestions",
                  excludeSemantics: false,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        avatar: Icon(Icons.help_outline, size: 16),
                        label: Text("Help"),
                        onPressed: () => _voiceService.provideHelp(),
                      ),
                      ActionChip(
                        avatar: Icon(Icons.delete_outline, size: 16),
                        label: Text("Clear Chat"),
                        onPressed: _clearMessages,
                      ),
                      ActionChip(
                        avatar: Icon(Icons.record_voice_over, size: 16),
                        label: Text("Read Last Message"),
                        onPressed: _readLastMessage,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                // Input field and buttons
                Row(
                  children: [
                    // Text input field
                    Expanded(
                      child: Semantics(
                        label: "Message input field",
                        hint: "Double tap to type or use voice input",
                        textField: true,
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Ask about any scheme...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Voice input button with animation
                    Semantics(
                      label: "Voice input",
                      hint: "Double tap to speak",
                      button: true,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isListening ? _animation.value : 1.0,
                            child: FloatingActionButton(
                              heroTag: "voiceInputButton",
                              mini: true,
                              onPressed: _listen,
                              backgroundColor: isListening ? Colors.red : Theme.of(context).primaryColor,
                              child: Icon(
                                isListening ? Icons.mic : Icons.mic_none,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 4),
                    // Send button
                    Semantics(
                      label: "Send message",
                      hint: "Double tap to send",
                      button: true,
                      enabled: !_isLoading && _controller.text.isNotEmpty,
                      child: FloatingActionButton(
                        heroTag: "sendButton",
                        mini: true,
                        onPressed: _isLoading ? null : _sendMessage,
                        backgroundColor: _isLoading ? Colors.grey : Theme.of(context).primaryColor,
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      // Global voice command button
      floatingActionButton: Semantics(
        label: "Voice navigation",
        hint: "Double tap for voice commands",
        child: FloatingActionButton(
          heroTag: "globalVoiceButton",
          onPressed: () async {
            final result = await _voiceService.listen(
              prompt: "What would you like to do? Say 'help' for options.",
            );
            if (result != null && result.isNotEmpty) {
              if (result.toLowerCase().contains('send') && _controller.text.isNotEmpty) {
                _sendMessage();
              } else if (result.toLowerCase().contains('clear')) {
                _clearMessages();
              } else if (result.toLowerCase().contains('read last')) {
                _readLastMessage();
              } else if (result.toLowerCase().contains('help')) {
                _voiceService.provideHelp();
              } else {
                // If no command is recognized, treat it as a question
                _controller.text = result;
                _sendMessage();
              }
            }
          },
          child: Icon(Icons.record_voice_over),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
