import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'scheme_detail_screen.dart';
import 'account_page.dart';
import 'my_schemes_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

void _logout(BuildContext context) async {
  await _auth.signOut();
  Navigator.pushReplacementNamed(context, '/login');
}

Future<Map<String, dynamic>?> _fetchProfile() async {
  final user = _auth.currentUser;
  if (user == null) return null;
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  return doc.data();
}

Future<List<dynamic>?> _fetchSchemes(Map<String, dynamic> profile) async {
  final url = Uri.parse('http://192.168.1.2:5000/recommend');
  final response = await http.post(
    url,
    body: jsonEncode(profile),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['recommended_schemes'] ?? [];
  }
  return null;
}

class HomeScreenBody extends StatefulWidget {
  @override
  State<HomeScreenBody> createState() => HomeScreenBodyState();
}

class HomeScreenBodyState extends State<HomeScreenBody> {
  final TextEditingController goalController = TextEditingController();
  int currentPage = 1;
  List<dynamic> schemes = [];
  bool loading = false;
  String error = '';
  Map<String, dynamic>? profile;
  String? userName;

  Future<void> fetchSchemes({String? customGoal}) async {
    setState(() {
      loading = true;
      error = '';
    });

    profile = await _fetchProfile();
    if (profile == null) {
      setState(() {
        loading = false;
        error = 'User profile not found.';
      });
      return;
    }

    setState(() {
      userName = profile?['name'] ?? 'User';
    });

    final payload = {
      'situation': customGoal ?? (profile?['situation'] ?? 'Looking for investment schemes'),
      'income_group': profile?['income_group'] ?? profile?['annual_income'] ?? '',
      'social_category': profile?['social_category'] ?? profile?['category'] ?? '',
      'gender': profile?['gender'] ?? '',
      'age': profile?['age']?.toString() ?? '',
      'location': profile?['location'] ?? '',
    };

    final result = await _fetchSchemes(payload);
    if (result != null) {
      setState(() {
        schemes = result;
      });
    } else {
      setState(() {
        error = 'No data received from backend.';
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSchemes();
  }

  @override
  void dispose() {
    goalController.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    int totalPages = (schemes.length / 10).ceil();
    int startIdx = (currentPage - 1) * 10;
    int endIdx = (startIdx + 10).clamp(0, schemes.length);
    List<dynamic> pageSchemes = schemes.sublist(startIdx, endIdx);

    Widget _buildHomeContent() {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.menu, color: Colors.black87),
                    Text(
                      'Welcome, ${userName ?? 'User'}!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    Row(
                      children: [
                        Icon(Icons.notifications_none, color: Colors.black54),
                        SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade400,
                          child: Text(
                            userName != null ? userName![0].toUpperCase() : '',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: goalController,
                        decoration: InputDecoration(
                          hintText: 'Search your goal or need',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          prefixIcon: Icon(Icons.search, color: Colors.pinkAccent),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        minLines: 1,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: loading
                          ? null
                          : () async {
                              currentPage = 1;
                              await fetchSchemes(customGoal: goalController.text.isNotEmpty ? goalController.text : null);
                            },
                      icon: loading
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Icon(Icons.search, color: Colors.white),
                      label: loading ? Text('') : Text('Find', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
                  child: Text(error, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: pageSchemes.length,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final scheme = pageSchemes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SchemeDetailScreen(schemeName: scheme['scheme_name'] ?? ''),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.auto_graph, color: Colors.pinkAccent, size: 28),
                          SizedBox(height: 10),
                          Text(
                            scheme['scheme_name'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          if (scheme['total_returns'] != null)
                            Text('Return: ${scheme['total_returns']}', style: TextStyle(fontSize: 13)),
                          if (scheme['risk'] != null)
                            Text('Risk: ${scheme['risk']}', style: TextStyle(fontSize: 13)),
                          if (scheme['time_duration'] != null)
                            Text('Term: ${scheme['time_duration']}', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    List<Widget> _tabContents = [
      _buildHomeContent(),
      Center(child: Text('Support page coming soon!', style: TextStyle(fontSize: 18))),
      MySchemesPage(),
      Center(child: Text('Micro Loans page coming soon!', style: TextStyle(fontSize: 18))),
      Center(child: Text('Community page coming soon!', style: TextStyle(fontSize: 18))),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF8F9FC),
        ),
        child: _tabContents[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Micro Loans'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
        ],
      ),
    );
  }
}
