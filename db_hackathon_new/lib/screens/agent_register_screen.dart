import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class AgentRegisterScreen extends StatefulWidget {
  @override
  _AgentRegisterScreenState createState() => _AgentRegisterScreenState();
}

class _AgentRegisterScreenState extends State<AgentRegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String orgType = 'Individual';
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _regionController = TextEditingController();
  final _proofController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  // Voice feature fields
  FlutterTts? flutterTts;
  bool isListening = false;
  static const platform = MethodChannel('voice_channel');

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("Agent Registration screen. Please fill in all the required fields to register as an agent.");
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _regionController.dispose();
    _proofController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agent Registration'),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.orange),
            onPressed: () => _speak("Agent Registration screen. Please fill in all the required fields to register as an agent."),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: orgType,
                      decoration: InputDecoration(labelText: 'Organization Type'),
                      items: ['Individual', 'Organization']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) {
                        setState(() => orgType = val ?? 'Individual');
                        _speak("Organization type selected: $orgType");
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.volume_up, color: Colors.orange),
                    onPressed: () => _speak("Organization Type: $orgType. Tap to change between Individual or Organization."),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: isListening ? Colors.red : Colors.orange,
                        ),
                        onPressed: () => _listen(_nameController),
                      ),
                      IconButton(
                        icon: Icon(Icons.volume_up, color: Colors.orange),
                        onPressed: () {
                          if (_nameController.text.isNotEmpty) {
                            _speak("Name: ${_nameController.text}");
                          } else {
                            _speak("Name field is empty");
                          }
                        },
                      ),
                    ],
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: isListening ? Colors.red : Colors.orange,
                        ),
                        onPressed: () => _listen(_contactController),
                      ),
                      IconButton(
                        icon: Icon(Icons.volume_up, color: Colors.orange),
                        onPressed: () {
                          if (_contactController.text.isNotEmpty) {
                            _speak("Contact Number: ${_contactController.text}");
                          } else {
                            _speak("Contact Number field is empty");
                          }
                        },
                      ),
                    ],
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Enter contact number' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _regionController,
                decoration: InputDecoration(
                  labelText: 'Region',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: isListening ? Colors.red : Colors.orange,
                        ),
                        onPressed: () => _listen(_regionController),
                      ),
                      IconButton(
                        icon: Icon(Icons.volume_up, color: Colors.orange),
                        onPressed: () {
                          if (_regionController.text.isNotEmpty) {
                            _speak("Region: ${_regionController.text}");
                          } else {
                            _speak("Region field is empty");
                          }
                        },
                      ),
                    ],
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter region' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _proofController,
                decoration: InputDecoration(
                  labelText: 'Proof (ID/Document)',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: isListening ? Colors.red : Colors.orange,
                        ),
                        onPressed: () => _listen(_proofController),
                      ),
                      IconButton(
                        icon: Icon(Icons.volume_up, color: Colors.orange),
                        onPressed: () {
                          if (_proofController.text.isNotEmpty) {
                            _speak("Proof: ${_proofController.text}");
                          } else {
                            _speak("Proof field is empty");
                          }
                        },
                      ),
                    ],
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter proof' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'Agent ID',
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
                validator: (v) => v == null || v.isEmpty ? 'Enter agent ID' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
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
                validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _speak("Processing registration");
                    final agentId = _idController.text.trim();
                    final password = _passwordController.text.trim();
                    final email = agentId + '@agents.com';
                    try {
                      // Create agent in Firebase Auth
                      await _auth.createUserWithEmailAndPassword(email: email, password: password);
                      // Save agent info in Firestore
                      await _firestore.collection('agents').doc(agentId).set({
                        'orgType': orgType,
                        'name': _nameController.text.trim(),
                        'contact': _contactController.text.trim(),
                        'region': _regionController.text.trim(),
                        'proof': _proofController.text.trim(),
                        'agentId': agentId,
                        'email': email,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      _speak("Agent registered successfully! Returning to previous screen.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Agent registered successfully!')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      _speak("Registration failed. Please try again.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registration failed: ' + e.toString())),
                      );
                    }
                  } else {
                    _speak("Please fill in all required fields correctly.");
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
