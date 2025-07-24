import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

const Color kAppPink = Color(0xFFE91E63); // Main pink color

class MySchemesPage extends StatefulWidget {
  const MySchemesPage({Key? key}) : super(key: key);

  @override
  State<MySchemesPage> createState() => _MySchemesPageState();
}

class _MySchemesPageState extends State<MySchemesPage> {
  FlutterTts? flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("My Profile page. View your personal information, financial summary, and active schemes.");
    });
  }

  @override
  void dispose() {
    flutterTts?.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (flutterTts != null) {
      await flutterTts!.speak(text);
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> fetchMySchemes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data == null || data['my_schemes'] == null) return [];
    return List<Map<String, dynamic>>.from(data['my_schemes']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppPink,
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            tooltip: 'Change Language',
            onPressed: () => _showLanguageDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.white),
            onPressed: () => _speak("My Profile page. View your personal information, financial summary, and active schemes."),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              _speak("Edit Profile");
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              _speak("Logging out");
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchUserProfile(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: kAppPink));
          }
          final user = userSnapshot.data;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // User Info Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: kAppPink.withOpacity(0.2),
                        radius: 32,
                        child: Text(
                          user?['name'] != null && user!['name'].isNotEmpty
                              ? user['name'][0].toUpperCase()
                              : 'U',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kAppPink),
                        ),
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?['name'] ?? 'User',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text('Active User', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.volume_up, color: kAppPink),
                        onPressed: () {
                          String userName = user?['name'] ?? 'User';
                          _speak("Profile: $userName, Active User");
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Contact Info Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Contact Information', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: kAppPink, size: 20),
                            onPressed: () {
                              String email = user?['email'] ?? 'No email';
                              String phone = user?['phone'] ?? 'No phone';
                              String location = user?['location'] ?? 'No location';
                              _speak("Contact Information. Email: $email. Phone: $phone. Location: $location.");
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 20, color: kAppPink),
                          SizedBox(width: 8),
                          Expanded(child: Text(user?['email'] ?? 'No email')),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: kAppPink, size: 16),
                            onPressed: () => _speak("Email: ${user?['email'] ?? 'No email'}"),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 20, color: kAppPink),
                          SizedBox(width: 8),
                          Expanded(child: Text(user?['phone'] ?? 'No phone')),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: kAppPink, size: 16),
                            onPressed: () => _speak("Phone: ${user?['phone'] ?? 'No phone'}"),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 20, color: kAppPink),
                          SizedBox(width: 8),
                          Expanded(child: Text(user?['location'] ?? 'No location')),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: kAppPink, size: 16),
                            onPressed: () => _speak("Location: ${user?['location'] ?? 'No location'}"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Financial Summary
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchMySchemes(),
                  builder: (context, schemesSnapshot) {
                    final schemes = schemesSnapshot.data ?? [];
                    final totalSavings = user?['savings']?.toString() ?? '0';
                    final activeSchemes = schemes.length;
                    final investmentReturns = user?['returns']?.toString() ?? '+0';
                    final goalsAchieved = user?['goals']?.toString() ?? '0';

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Financial Summary',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.volume_up, color: kAppPink),
                              onPressed: () {
                                _speak("Financial Summary. Total Savings: $totalSavings rupees. Active Schemes: $activeSchemes. Investment Returns: $investmentReturns rupees. Goals Achieved: $goalsAchieved");
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _snapshotCard(
                              icon: Icons.savings_outlined,
                              title: 'Total Savings',
                              value: '₹$totalSavings',
                              subtitle: '+1.2% this month',
                            ),
                            _snapshotCard(
                              icon: Icons.assignment_turned_in_outlined,
                              title: 'Active Schemes',
                              value: '$activeSchemes',
                              subtitle: 'Joined ${activeSchemes > 0 ? '1 new' : 'none'}',
                            ),
                            _snapshotCard(
                              icon: Icons.trending_up,
                              title: 'Investment Returns',
                              value: '₹$investmentReturns',
                              subtitle: '+5% last quarter',
                            ),
                            _snapshotCard(
                              icon: Icons.flag_outlined,
                              title: 'Goals Achieved',
                              value: '$goalsAchieved',
                              subtitle: 'On track for 3 more',
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24),
                // Schemes List
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recent Activities & Tips',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: kAppPink),
                      onPressed: () => _speak("Recent Activities and Tips section"),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchMySchemes(),
                  builder: (context, snapshot) {
                    final schemes = snapshot.data ?? [];
                    if (schemes.isEmpty) {
                      return Column(
                        children: [
                          Center(child: Text('No schemes registered yet.')),
                          SizedBox(height: 8),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: kAppPink),
                            onPressed: () => _speak("No schemes registered yet. You can explore new schemes from the home page."),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: schemes.length,
                      itemBuilder: (context, index) {
                        final scheme = schemes[index];
                        final name = scheme['scheme_name'] ?? 'Unnamed Scheme';
                        final amount = scheme['amount'];
                        final regDate = scheme['registered_at'] != null ? DateTime.tryParse(scheme['registered_at']) : null;
                        final dueDate = scheme['due_date'] != null ? DateTime.tryParse(scheme['due_date']) : null;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kAppPink)),
                                    if (amount != null) Text('Amount: ₹$amount'),
                                    if (regDate != null)
                                      Text('Registered on: ${regDate.toLocal().toString().split(' ')[0]}'),
                                    if (dueDate != null)
                                      Text('Next Due Date: ${dueDate.toLocal().toString().split(' ')[0]}'),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.volume_up, color: kAppPink),
                                onPressed: () {
                                  String schemeInfo = "Scheme: $name";
                                  if (amount != null) schemeInfo += ". Amount: $amount rupees";
                                  if (regDate != null) schemeInfo += ". Registered on: ${regDate.toLocal().toString().split(' ')[0]}";
                                  if (dueDate != null) schemeInfo += ". Next due date: ${dueDate.toLocal().toString().split(' ')[0]}";
                                  _speak(schemeInfo);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _snapshotCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _speak("$title: $value. $subtitle"),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 28, color: kAppPink),
              SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.green)),
              SizedBox(height: 4),
              Icon(Icons.volume_up, color: kAppPink, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, 'English', 'en'),
            _languageOption(context, 'हिन्दी', 'hi'),
            _languageOption(context, 'मराठी', 'mr'),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext context, String label, String code) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Provider.of<LanguageProvider>(context, listen: false).setLanguage(code);
        Navigator.of(context).pop();
        _speak("$label selected");
      },
    );
  }
}
