import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> features = [
    {
      'icon': Icons.location_on,
      'title': 'Location Based',
      'description': 'Get personalized schemes based on your location and preferred language',
      'color': Colors.blue,
    },
    {
      'icon': Icons.support_agent,
      'title': 'Expert Support',
      'description': 'Chat or call local agents for personalized assistance',
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                '🪔 योजना Finance Guide',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your personalized guide to government and private financial schemes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield, color: Colors.green, size: 18),
                  SizedBox(width: 4),
                  Text('Secure & Trusted', style: TextStyle(color: Colors.green)),
                  SizedBox(width: 16),
                  Icon(Icons.auto_graph, color: Colors.blue, size: 18),
                  SizedBox(width: 4),
                  Text('AI Powered', style: TextStyle(color: Colors.blue)),
                ],
              ),
              SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  itemCount: features.length,
                  separatorBuilder: (_, __) => SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(feature['icon'], size: 40, color: feature['color']),
                          SizedBox(height: 10),
                          Text(
                            feature['title'],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            feature['description'],
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('Register', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
