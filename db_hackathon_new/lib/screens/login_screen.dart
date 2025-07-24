import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import '../gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
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
      final loc = AppLocalizations.of(context)!;
      _speak(loc.welcomeLoginMessage);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
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
    final loc = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    _speak(loc.loggingIn);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _speak(loc.loginSuccessMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.loginSuccess)),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _speak(loc.loginFailedMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.loginFailed}: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.trending_up, color: Colors.white, size: 16),
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                loc.loginToFinWise,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Color(0xFF1A237E)),
            onPressed: () => _speak(loc.welcomeLoginMessage),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              // Illustration and welcome text
              Container(
                height: 120,
                child: Image.asset(
                  'assets/images/welcome_bg.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 60, color: Color(0xFF1A237E)),
                          SizedBox(height: 8),
                          Text(
                            loc.welcomeBack,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Text(
                loc.welcomeBack,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 6),
              Text(
                loc.loginDescription,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              // Form fields
              Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: loc.emailOrUsername,
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'Roboto',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF1A237E)),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isListening ? Icons.mic : Icons.mic_none,
                              color: isListening ? Colors.red : Color(0xFF1A237E),
                            ),
                            onPressed: () => _listen(_emailController),
                          ),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: Color(0xFF1A237E)),
                            onPressed: () {
                              if (_emailController.text.isNotEmpty) {
                                _speak("${loc.email}: ${_emailController.text}");
                              } else {
                                _speak(loc.emailFieldEmpty);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontFamily: 'Roboto'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: loc.password,
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'Roboto',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF1A237E)),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility_off, color: Colors.grey[600]),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              isListening ? Icons.mic : Icons.mic_none,
                              color: isListening ? Colors.red : Color(0xFF1A237E),
                            ),
                            onPressed: () => _listen(_passwordController),
                          ),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: Color(0xFF1A237E)),
                            onPressed: () {
                              if (_passwordController.text.isNotEmpty) {
                                _speak(loc.passwordEntered);
                              } else {
                                _speak(loc.passwordFieldEmpty);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    style: TextStyle(fontFamily: 'Roboto'),
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _speak(loc.forgotPassword);
                        // Add forgot password logic here
                      },
                      child: Text(
                        loc.forgotPassword,
                        style: TextStyle(
                          color: Color(0xFF1A237E),
                          fontFamily: 'Roboto',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A237E),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loc.logInSecurely,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.volume_up, color: Colors.white, size: 18),
                              onPressed: () => _speak(loc.loginButtonDescription),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16),
              
              // OR divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      loc.or,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'Roboto',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              SizedBox(height: 16),
              
              // Additional options
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _speak(loc.openingChatbot);
                        Navigator.pushNamed(context, '/chatbot');
                      },
                      icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[700], size: 18),
                      label: Text(
                        loc.continueWithChatbot,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontFamily: 'Roboto',
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _speak(loc.openingAgentLogin);
                        Navigator.pushNamed(context, '/agent-login');
                      },
                      icon: Icon(Icons.person_outline, color: Colors.grey[700], size: 18),
                      label: Text(
                        loc.continueAsAgent,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontFamily: 'Roboto',
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _speak(loc.openingAgentRegistration);
                        Navigator.pushNamed(context, '/agent-register');
                      },
                      icon: Icon(Icons.person_add_outlined, color: Colors.grey[700], size: 18),
                      label: Text(
                        loc.registerAsAgent,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontFamily: 'Roboto',
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              // Don't have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.dontHaveAccountRegister,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Roboto',
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _speak(loc.createNewProfile);
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: Text(
                      loc.registerAsNewUser,
                      style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.volume_up, color: Color(0xFF1A237E), size: 16),
                    onPressed: () => _speak(loc.createNewProfileDescription),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 20), // Added bottom padding
            ],
          ),
        ),
      ),
    );
  }
}