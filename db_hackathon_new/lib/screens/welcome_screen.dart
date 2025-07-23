import 'package:flutter/material.dart';
import '../gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// The welcome screen for the Scheme Recommender app.
/// Shows app features and navigation actions.
class WelcomeScreen extends StatelessWidget {
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
  static Widget _buildActionButton({
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
            child: _WelcomeScreenContent(),
          ),
        ),
      ),
    );
  }
}

/// Extracted content widget for WelcomeScreen to improve readability and const usage.
class _WelcomeScreenContent extends StatelessWidget {
  const _WelcomeScreenContent();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final features = WelcomeScreen.features(context);

    return Column(
      children: [
        const SizedBox(height: 32),
        Text(
          loc.appTitle,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
            letterSpacing: 1.2,
            shadows: [Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
          ),
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
            Chip(
              avatar: const Icon(Icons.shield, color: Colors.green, size: 18),
              label: Text(loc.secureTrusted, style: const TextStyle(color: Colors.green)),
              backgroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(width: 12),
            Chip(
              avatar: const Icon(Icons.auto_graph, color: Colors.blue, size: 18),
              label: Text(loc.aiPowered, style: const TextStyle(color: Colors.blue)),
              backgroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              return Container(
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
                    Container(
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
            WelcomeScreen._buildActionButton(
              context: context,
              label: loc.login,
              color: Color(0xFF27ae60),
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
            WelcomeScreen._buildActionButton(
              context: context,
              label: loc.register,
              color: Color(0xFF2980b9),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
            WelcomeScreen._buildActionButton(
              context: context,
              label: loc.chatbot,
              color: Color(0xFF8e44ad),
              icon: Icons.chat_bubble_outline,
              onPressed: () => Navigator.pushNamed(context, '/chatbot'),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}