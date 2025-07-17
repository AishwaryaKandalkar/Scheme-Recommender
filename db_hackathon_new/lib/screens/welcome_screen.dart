import 'package:flutter/material.dart';
import '../gen_l10n/app_localizations.dart';

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
      backgroundColor: const Color(0xFFF1F4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _WelcomeScreenContent(),
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
        const SizedBox(height: 20),
        Text(
          loc.appTitle,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.appSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, color: Colors.green, size: 18),
            const SizedBox(width: 4),
            Text(loc.secureTrusted, style: const TextStyle(color: Colors.green)),
            const SizedBox(width: 16),
            const Icon(Icons.auto_graph, color: Colors.blue, size: 18),
            const SizedBox(width: 4),
            Text(loc.aiPowered, style: const TextStyle(color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 28),
        Expanded(
          child: ListView.separated(
            itemCount: features.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(feature['icon'], size: 40, color: feature['color']),
                    const SizedBox(height: 10),
                    Text(
                      feature['title'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['description'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            WelcomeScreen._buildActionButton(
              context: context,
              label: loc.login,
              color: Colors.green,
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
            WelcomeScreen._buildActionButton(
              context: context,
              label: loc.register,
              color: Colors.blue,
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
            WelcomeScreen._buildActionButton(
              context: context,
              label: loc.chatbot,
              color: Colors.purple,
              icon: Icons.chat_bubble_outline,
              onPressed: () => Navigator.pushNamed(context, '/chatbot'),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}