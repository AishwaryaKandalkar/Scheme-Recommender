
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// TODO: Move to config or env for production
const String chatbotApiUrl = 'http://192.168.1.8:5000/chatbot';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

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
        setState(() {
          _messages.add({'role': 'bot', 'text': data['answer'] ?? 'No response.'});
        });
      } else {
        setState(() {
          _messages.add({'role': 'bot', 'text': 'Error: Could not get response from server.'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': 'Network error: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schemes Chatbot')),
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
                    child: Text(msg['text'] ?? '', style: TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
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
                      hintText: 'Ask about any scheme...'
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
