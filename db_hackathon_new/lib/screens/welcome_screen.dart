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
      _speak(AppLocalizations.of(context)!.welcomeToSchemeRecommender);
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
          'icon': Icons.mic,
          'title': AppLocalizations.of(context)!.voiceAssistant,
          'description': AppLocalizations.of(context)!.voiceAssistantDescription,
          'color': Color(0xFF1A237E),
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
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
                loc.financeInclude,
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: _WelcomeScreenContent(parent: this),
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
        const SizedBox(height: 20),
        // Main logo and title section
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Color(0xFF1A237E),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.trending_up, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 16),
        Text(
          loc.pathToFinancialSuccess,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Roboto',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            loc.financialToolsDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    parent._speak("Opening registration form");
                    Navigator.pushNamed(context, '/profile');
                  },
                  icon: Icon(Icons.play_arrow, color: Colors.white, size: 18),
                  label: Text(
                    loc.register,
                    style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A237E),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    parent._speak("Opening login screen");
                    Navigator.pushNamed(context, '/login');
                  },
                  icon: Icon(Icons.person_outline, color: Colors.grey[700], size: 18),
                  label: Text(
                    loc.alreadyHaveAccount,
                    style: TextStyle(color: Colors.grey[700], fontFamily: 'Roboto', fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Features section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features.map((feature) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => parent._speakFeature(feature),
                  child: Column(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: feature['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          feature['icon'],
                          color: feature['color'],
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        feature['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6),
                      Container(
                        height: 60, // Fixed height for description
                        child: Text(
                          feature['description'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Bottom CTA section - Expanded to fill remaining space
        Expanded(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF50C878)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings, color: Colors.white, size: 28),
                SizedBox(height: 10),
                Text(
                  loc.unsureWhatYouNeed,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Text(
                  loc.browseSchemes,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    parent._speak("Opening AI chatbot");
                    Navigator.pushNamed(context, '/chatbot');
                  },
                  icon: Icon(Icons.person_outline, color: Colors.black87, size: 18),
                  label: Text(
                    loc.continueAsGuest,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}