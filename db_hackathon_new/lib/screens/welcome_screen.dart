import 'package:flutter/material.dart';
import '../gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

/// The welcome screen for the Scheme Recommender app.
/// Shows app features and navigation actions.
class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  FlutterTts? _flutterTts;
  static const MethodChannel _voiceChannel = MethodChannel('voice_channel');

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("Welcome to Scheme Recommender! Your AI-powered financial companion for discovering government schemes.");
    });
  }

  @override
  void dispose() {
    _flutterTts?.stop();
    super.dispose();
  }

  void _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts?.setLanguage("en-US");
    await _flutterTts?.setSpeechRate(0.5);
    await _flutterTts?.setVolume(1.0);
    await _flutterTts?.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts?.speak(text);
  }

  void _speakAppOverview() {
    _speak("Scheme Recommender helps you discover personalized government schemes. We offer location-based recommendations and expert support. You can login, register a new account, or chat with our AI assistant to get started.");
  }

  void _speakFeature(Map<String, dynamic> feature) {
    _speak("${feature['title']}: ${feature['description']}");
  }

  Future<void> _startVoiceNavigation() async {
    try {
      await _speak("Say 'login', 'register', or 'chatbot' to navigate");
      final result = await _voiceChannel.invokeMethod('startListening');
      if (result != null && result.isNotEmpty) {
        final command = result.toLowerCase();
        if (command.contains('login')) {
          await _speak("Navigating to login");
          Navigator.pushNamed(context, '/login');
        } else if (command.contains('register') || command.contains('sign up')) {
          await _speak("Navigating to registration");
          Navigator.pushNamed(context, '/profile');
        } else if (command.contains('chat') || command.contains('bot')) {
          await _speak("Opening chatbot");
          Navigator.pushNamed(context, '/chatbot');
        } else {
          await _speak("Command not recognized. Please try again or use the buttons.");
        }
      }
    } catch (e) {
      await _speak("Voice navigation failed. Please use the buttons.");
    }
  }

  static List<Map<String, dynamic>> features(BuildContext context) => [
        {
          'icon': Icons.location_on,
          'title': AppLocalizations.of(context)!.locationBased,
          'description': AppLocalizations.of(context)!.locationBasedDescription,
          'color': Colors.blue,
        },
        {
          'icon': Icons.support_agent,
          'title': AppLocalizations.of(context)!.expertSupport,
          'description': AppLocalizations.of(context)!.expertSupportDescription,
          'color': Colors.purple,
        },
      ];

  /// Builds a styled action button for navigation.
  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        label: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.white),
            onPressed: () => _speakAppOverview(),
          ),
          IconButton(
            icon: Icon(Icons.mic, color: Colors.white),
            onPressed: () => _startVoiceNavigation(),
          ),
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _speak("Welcome to Scheme Recommender! Use voice navigation by tapping the microphone, or explore features and tap the action buttons below."),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A85B6), Color(0xFFbac8e0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _WelcomeScreenContent(parent: this),
          ),
        ),
      ),
    );
  }
}

/// Extracted content widget for WelcomeScreen to improve readability and const usage.
class _WelcomeScreenContent extends StatelessWidget {
  final _WelcomeScreenState parent;
  
  const _WelcomeScreenContent({required this.parent});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final features = _WelcomeScreenState.features(context);

    return Column(
      children: [
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: Text(
                loc.appTitle,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  letterSpacing: 1.2,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.volume_up, color: Color(0xFF2C3E50)),
              onPressed: () => parent._speak("${loc.appTitle}. ${loc.appSubtitle}"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          loc.appSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            color: Color(0xFF34495E),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => parent._speak("Secure and Trusted platform"),
              child: Chip(
                avatar: const Icon(Icons.shield, color: Colors.green, size: 18),
                label: Text(loc.secureTrusted, style: const TextStyle(color: Colors.green)),
                backgroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => parent._speak("AI Powered recommendations"),
              child: Chip(
                avatar: const Icon(Icons.auto_graph, color: Colors.blue, size: 18),
                label: Text(loc.aiPowered, style: const TextStyle(color: Colors.blue)),
                backgroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: features.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final feature = features[index];
              return GestureDetector(
                onTap: () => parent._speakFeature(feature),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0x336A85B6), blurRadius: 16, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [feature['color'], Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Icon(feature['icon'], size: 48, color: feature['color']),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: feature['color']),
                            onPressed: () => parent._speakFeature(feature),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        feature['title'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        feature['description'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 15),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            parent._buildActionButton(
              context: context,
              label: loc.login,
              color: Color(0xFF27ae60),
              onPressed: () {
                parent._speak("Opening login screen");
                Navigator.pushNamed(context, '/login');
              },
            ),
            parent._buildActionButton(
              context: context,
              label: loc.register,
              color: Color(0xFF2980b9),
              onPressed: () {
                parent._speak("Opening registration form");
                Navigator.pushNamed(context, '/profile');
              },
            ),
            parent._buildActionButton(
              context: context,
              label: loc.chatbot,
              color: Color(0xFF8e44ad),
              icon: Icons.chat_bubble_outline,
              onPressed: () {
                parent._speak("Opening AI chatbot");
                Navigator.pushNamed(context, '/chatbot');
              },
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}