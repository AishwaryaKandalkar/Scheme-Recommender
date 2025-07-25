import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import '../gen_l10n/app_localizations.dart';
import '../utils/session_manager.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Voice feature fields
  FlutterTts? flutterTts;
  bool isListening = false;
  static const platform = MethodChannel('voice_channel');

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _loadRememberedCredentials();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("Welcome to Scheme Recommender Login. Enter your credentials to access your account, or explore other options like chatbot or agent services.");
    });
  }

  Future<void> _loadRememberedCredentials() async {
    final credentials = await SessionManager.getRememberedCredentials();
    if (credentials['rememberMe'] == 'true') {
      setState(() {
        _phoneController.text = credentials['email'] ?? '';
        _passwordController.text = credentials['password'] ?? '';
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
    _speak("Logging in");
    try {
      // Convert phone to email format for Firebase Auth
      String email = "${_phoneController.text.trim()}@phone.local";
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );
      
      // Save session and remember credentials if enabled
      if (credential.user != null) {
        await SessionManager.saveSession(credential.user!);
        
        if (_rememberMe) {
          await SessionManager.saveRememberedCredentials(
            _phoneController.text.trim(),
            _passwordController.text.trim(),
          );
        } else {
          await SessionManager.clearRememberedCredentials();
        }
      }
      
      _speak("Login successful! Redirecting to home screen.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.loginSuccess)),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _speak("Login failed. Please check your credentials and try again.");
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
      backgroundColor: Color(0xFFF7FAFE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.blue),
            onPressed: () => _speak("Welcome to Scheme Recommender Login. Enter your credentials to access your account, or explore other options like chatbot or agent services."),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_open, size: 60, color: Colors.blue),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: Colors.blue),
                      onPressed: () => _speak("Login"),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.login,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: Colors.blue, size: 20),
                      onPressed: () => _speak(loc.login),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: loc.phone,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            color: isListening ? Colors.red : Colors.blue,
                          ),
                          onPressed: () => _listen(_phoneController),
                        ),
                        IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.blue),
                          onPressed: () {
                            if (_phoneController.text.isNotEmpty) {
                              _speak("Phone: ${_phoneController.text}");
                            } else {
                              _speak("Phone field is empty");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: loc.password,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                            _speak(_obscurePassword ? "Password hidden" : "Password visible");
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            color: isListening ? Colors.red : Colors.blue,
                          ),
                          onPressed: () => _listen(_passwordController),
                        ),
                        IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.blue),
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
                SizedBox(height: 16),
                
                // Remember Me Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                        _speak(_rememberMe ? "Remember me enabled" : "Remember me disabled");
                      },
                      activeColor: Colors.blue,
                    ),
                    Text('Remember me'),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: Colors.blue, size: 16),
                      onPressed: () => _speak("Remember me option. Enable this to save your login credentials securely."),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 45),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(loc.login),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: Colors.blue),
                      onPressed: () => _speak("Login button. Tap to sign in to your account."),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        _speak("Don't have an account? Create profile");
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: Text(loc.dontHaveAccount,
                          style: TextStyle(color: Colors.blue)),
                    ),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: Colors.blue, size: 16),
                      onPressed: () => _speak("Don't have an account? Create a new profile to get started."),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _speak("Opening chatbot");
                          Navigator.pushNamed(context, '/chatbot');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 45),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(loc.chatbot, style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: Colors.green),
                      onPressed: () => _speak("Chatbot. Ask questions about financial schemes without logging in."),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _speak("Opening agent login");
                          Navigator.pushNamed(context, '/agent-login');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 45),
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Agent Login', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: Colors.orange),
                      onPressed: () => _speak("Agent Login. For financial advisors and scheme consultants."),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _speak("Opening agent registration");
                          Navigator.pushNamed(context, '/agent-register');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 45),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Register as Agent', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: Colors.deepPurple),
                      onPressed: () => _speak("Register as Agent. Sign up to become a financial advisor on our platform."),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}