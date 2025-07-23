import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'scheme_detail_screen.dart';
import 'account_page.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'my_schemes_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;


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

  // Voice feature fields
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    // Automatically fetch eligible schemes on home page load
    fetchSchemes();
    speech = stt.SpeechToText();
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _listen(TextEditingController controller) async {
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        setState(() => isListening = true);
        speech.listen(onResult: (result) {
          controller.text = result.recognizedWords;
        });
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }
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
                          suffixIcon: IconButton(
                            icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: Colors.blueAccent),
                            onPressed: () => _listen(goalController),
                          ),
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
                  child: Row(
                    children: [
                      Expanded(child: Text(error, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                      IconButton(
                        icon: Icon(Icons.volume_up, color: Colors.red),
                        onPressed: () => _speak(error),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(minHeight: 300),
                child: pageSchemes.isEmpty && !loading && error.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey, size: 48),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('No eligible recommendations found.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                IconButton(
                                  icon: Icon(Icons.volume_up, color: Colors.grey),
                                  onPressed: () => _speak('No eligible recommendations found.'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: pageSchemes.length,
                        itemBuilder: (context, index) {
                          final scheme = pageSchemes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Color(0xFFe3f0ff)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade100,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SchemeDetailScreen(
                                          schemeName: scheme['scheme_name'] ?? ''),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [Colors.orangeAccent, Colors.yellow.shade100],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            padding: EdgeInsets.all(6),
                                            child: Icon(Icons.star, color: Colors.white, size: 24),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    scheme['scheme_name'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 21,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.blue.shade800,
                                                      decoration: TextDecoration.underline,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.volume_up, color: Colors.blueAccent),
                                                  onPressed: () => _speak(scheme['scheme_name'] ?? ''),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      if ((scheme['scheme_goal'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.flag, color: Colors.green, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(child: Text('Goal: ${scheme['scheme_goal']}', style: TextStyle(fontSize: 16))),
                                                  IconButton(
                                                    icon: Icon(Icons.volume_up, color: Colors.green),
                                                    onPressed: () => _speak('Goal: ${scheme['scheme_goal']}'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      if ((scheme['benefits'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.thumb_up, color: Colors.blueAccent, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(child: Text('Benefits: ${scheme['benefits']}', style: TextStyle(fontSize: 16))),
                                                  IconButton(
                                                    icon: Icon(Icons.volume_up, color: Colors.blueAccent),
                                                    onPressed: () => _speak('Benefits: ${scheme['benefits']}'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      if ((scheme['total_returns'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.trending_up, color: Colors.purple, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(child: Text('Returns: ${scheme['total_returns']}', style: TextStyle(fontSize: 16))),
                                                  IconButton(
                                                    icon: Icon(Icons.volume_up, color: Colors.purple),
                                                    onPressed: () => _speak('Returns: ${scheme['total_returns']}'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      if ((scheme['time_duration'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.timer, color: Colors.teal, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(child: Text('Duration: ${scheme['time_duration']}', style: TextStyle(fontSize: 16))),
                                                  IconButton(
                                                    icon: Icon(Icons.volume_up, color: Colors.teal),
                                                    onPressed: () => _speak('Duration: ${scheme['time_duration']}'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      if ((scheme['scheme_website'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.link, color: Colors.indigo, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(child: Text('Website: ${scheme['scheme_website']}', style: TextStyle(fontSize: 16, color: Colors.indigo))),
                                                  IconButton(
                                                    icon: Icon(Icons.volume_up, color: Colors.indigo),
                                                    onPressed: () => _speak('Website: ${scheme['scheme_website']}'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      if ((scheme['similarity_score'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.score, color: Colors.deepOrange, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(child: Text('Match Score: ${scheme['similarity_score']?.toStringAsFixed(2) ?? ''}', style: TextStyle(fontSize: 16))),
                                                  IconButton(
                                                    icon: Icon(Icons.volume_up, color: Colors.deepOrange),
                                                    onPressed: () => _speak('Match Score: ${scheme['similarity_score']?.toStringAsFixed(2) ?? ''}'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ));
                          },
                        ),
              ),
              if (pageSchemes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPages, (i) {
                      final pageNum = i + 1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              currentPage = pageNum;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.blueAccent),
                            backgroundColor: currentPage == pageNum
                                ? Colors.blue.shade50
                                : Colors.white,
                          ),
                          child: Text('$pageNum'),
                        ),
                      );
                    }),
                  ),
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
