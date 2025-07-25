import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import '../gen_l10n/app_localizations.dart';
import 'scheme_detail_screen.dart';
import 'my_schemes_page.dart';
import 'community_page.dart';
import 'micro_loans_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<Map<String, dynamic>?> _fetchProfile() async {
  final user = _auth.currentUser;
  if (user == null) return null;
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  return doc.exists ? doc.data() : null;
}

class HomeScreenBody extends StatefulWidget {
  final String locale;

  const HomeScreenBody({Key? key, required this.locale}) : super(key: key);

  @override
  _HomeScreenBodyState createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  List<dynamic> schemes = [];
  List<dynamic> get _displayedSchemes {
    int startIndex = (currentPage - 1) * 10;
    int endIndex = startIndex + 10;
    if (endIndex > schemes.length) endIndex = schemes.length;
    return schemes.sublist(startIndex, endIndex);
  }

  bool loading = false;
  String? error;
  bool isAiSearch = false;
  TextEditingController goalController = TextEditingController();
  int _selectedIndex = 0;
  int currentPage = 1;
  FlutterTts? flutterTts;
  bool isListening = false;
  static const platform = MethodChannel('speech_recognition');

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadSchemes(null);
  }

  void _initTts() async {
    flutterTts = FlutterTts();
    await flutterTts!.setLanguage("en-US");
    await flutterTts!.setSpeechRate(0.5);
  }

  Future<List<dynamic>?> _fetchSchemes(Map<String, dynamic> payload, String lang) async {
    try {
      final response = await http.post(
        Uri.parse('https://api-hackathon-vxvo.onrender.com/fetch_schemes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['schemes'];
      }
      return null;
    } catch (e) {
      print('Error fetching schemes: $e');
      return null;
    }
  }

  Future<List<dynamic>?> _fetchEligibleSchemes(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('https://api-hackathon-vxvo.onrender.com/fetch_eligible_schemes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['schemes'];
      }
      return null;
    } catch (e) {
      print('Error fetching eligible schemes: $e');
      return null;
    }
  }

  Future<void> _loadSchemes(String? customGoal) async {
    setState(() {
      loading = true;
      error = null;
      currentPage = 1;
    });

    final profile = await _fetchProfile();
    if (profile == null) {
      setState(() {
        error = 'Profile not found. Please complete your profile.';
        loading = false;
      });
      return;
    }

    Map<String, dynamic> payload = {
      'age': profile['age'] ?? 25,
      'gender': profile['gender'] ?? 'Male',
      'annual_income': profile['annualIncome'] ?? 50000,
      'occupation': profile['occupation'] ?? 'Student',
      'state': profile['state'] ?? 'Maharashtra',
      'rural_urban': profile['location'] ?? 'Urban',
      'married_status': profile['maritalStatus'] ?? 'Single',
    };

    String lang = widget.locale == 'hi' ? 'hindi' : (widget.locale == 'mr' ? 'marathi' : 'english');
    List<dynamic>? result;

    if (customGoal != null && customGoal.trim().isNotEmpty) {
      setState(() {
        isAiSearch = true;
      });
      await _speak("Searching for schemes related to: $customGoal");
      payload['situation'] = customGoal;
      result = await _fetchSchemes(payload, lang);
    } else {
      setState(() {
        isAiSearch = false;
      });
      await _speak("Loading your eligible schemes");
      result = await _fetchEligibleSchemes(payload);
    }

    if (result != null) {
      setState(() {
        schemes = result!;
      });
      
      if (customGoal != null && customGoal.trim().isNotEmpty) {
        await _speak("Found ${result.length} schemes matching your search for $customGoal");
      } else {
        await _speak("Loaded ${result.length} schemes you're eligible for");
      }
    } else {
      setState(() {
        error = 'No data received from backend.';
      });
      await _speak("Failed to load schemes. Please try again.");
    }

    setState(() {
      loading = false;
    });
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

  List<Widget> _buildPageNumbers() {
    int totalPages = ((schemes.length - 1) ~/ 10) + 1;
    List<Widget> pageButtons = [];
    
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (currentPage + 2).clamp(1, totalPages);
    
    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                currentPage = i;
              });
              await _speak("Page $i");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: i == currentPage ? Colors.pinkAccent : Colors.grey[300],
              foregroundColor: i == currentPage ? Colors.white : Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size(32, 32),
            ),
            child: Text('$i'),
          ),
        ),
      );
    }
    return pageButtons;
  }

  Widget _buildSearchBar() {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: goalController,
              decoration: InputDecoration(
                hintText: loc.searchGoalOrNeed,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                prefixIcon: Icon(Icons.search, color: Colors.pinkAccent),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: isListening ? Colors.red : Colors.pinkAccent,
                      ),
                      onPressed: () => _listen(goalController),
                    ),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: Colors.pinkAccent),
                      onPressed: () {
                        if (goalController.text.isNotEmpty) {
                          _speak(goalController.text);
                        }
                      },
                    ),
                  ],
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onFieldSubmitted: (value) {
                _loadSchemes(value.trim());
              },
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.all(12),
              shape: CircleBorder(),
            ),
            onPressed: () {
              _loadSchemes(goalController.text.trim());
            },
            child: Icon(Icons.search, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    String title, 
    String description,
    IconData icon, 
    List<Color> gradientColors,
    VoidCallback onTap
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    Widget _buildHomeContent() {
      return SingleChildScrollView(
        padding: EdgeInsets.all(0),
        child: Column(
              children: [
                // Header Section with Services
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.pinkAccent,
                        Colors.purpleAccent,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'How can we help you today?',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Icon(Icons.person, color: Colors.white, size: 30),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Our Services',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.1,
                            children: [
                              _buildServiceCard(
                                'Community',
                                'Connect & Share',
                                Icons.people,
                                [Colors.blue, Colors.blueAccent],
                                () {
                                  setState(() => _selectedIndex = 4);
                                  _speak("Opening Community page");
                                },
                              ),
                              _buildServiceCard(
                                'Micro Loans',
                                'Business Finance',
                                Icons.account_balance_wallet,
                                [Colors.green, Colors.greenAccent],
                                () {
                                  setState(() => _selectedIndex = 3);
                                  _speak("Opening Micro Loans page");
                                },
                              ),
                              _buildServiceCard(
                                'AI Chatbot',
                                'Get Quick Help',
                                Icons.chat_bubble,
                                [Colors.purple, Colors.purpleAccent],
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('AI Chatbot coming soon!')),
                                  );
                                  _speak("AI Chatbot feature coming soon");
                                },
                              ),
                              _buildServiceCard(
                                'Support',
                                'Help & Assistance',
                                Icons.support_agent,
                                [Colors.orange, Colors.orangeAccent],
                                () {
                                  setState(() => _selectedIndex = 1);
                                  _speak("Opening Support page");
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Scheme Search Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Find Schemes',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: Colors.pinkAccent, size: 20),
                            onPressed: () => _speak("Scheme search section. Search for government schemes based on your needs."),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildSearchBar(),
                      SizedBox(height: 16),
                      
                      if (loading)
                        Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(isAiSearch ? 'AI is finding schemes for you...' : 'Finding your eligible schemes...'),
                            ],
                          ),
                        )
                      else if (error != null)
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text(
                                error!,
                                style: TextStyle(color: Colors.red, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _loadSchemes(goalController.text.trim()),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      else if (schemes.isNotEmpty) ...[
                        Container(
                          child: Row(
                            children: [
                              Text(
                                'Found ${schemes.length} schemes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                              ),
                              Spacer(),
                              if (isAiSearch)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                                      SizedBox(width: 4),
                                      Text('AI Powered', style: TextStyle(fontSize: 12, color: Colors.purple)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                          ),
                          itemCount: _displayedSchemes.length,
                          itemBuilder: (context, index) {
                            final scheme = _displayedSchemes[index];
                            return GestureDetector(
                              onTap: () async {
                                await _speak("Opening details for ${scheme['scheme_name']}");
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SchemeDetailScreen(
                                      schemeName: scheme['scheme_name'] ?? '',
                                      lang: widget.locale,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Icon(
                                              Icons.account_balance,
                                              color: Colors.pinkAccent,
                                              size: 24,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.volume_up, color: Colors.pinkAccent, size: 16),
                                            onPressed: () {
                                              String schemeInfo = scheme['scheme_name'] ?? '';
                                              if (scheme['total_returns'] != null) {
                                                schemeInfo += '. Returns: ${scheme['total_returns']}';
                                              }
                                              if (scheme['risk'] != null) {
                                                schemeInfo += '. Risk: ${scheme['risk']}';
                                              }
                                              if (scheme['time_duration'] != null) {
                                                schemeInfo += '. Term: ${scheme['time_duration']}';
                                              }
                                              _speak(schemeInfo);
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        scheme['scheme_name'] ?? '',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6),
                                      if (scheme['total_returns'] != null)
                                        Text('${loc.returns}: ${scheme['total_returns']}', style: TextStyle(fontSize: 13)),
                                      if (scheme['risk'] != null)
                                        Text('${loc.risk}: ${scheme['risk']}', style: TextStyle(fontSize: 13)),
                                      if (scheme['time_duration'] != null)
                                        Text('${loc.term}: ${scheme['time_duration']}', style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        
                        // Pagination controls
                        if (schemes.length > 10) ...[
                          Column(
                            children: [
                              Text(
                                'Page $currentPage of ${((schemes.length - 1) ~/ 10) + 1}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: currentPage > 1
                                        ? () async {
                                            setState(() {
                                              currentPage--;
                                            });
                                            await _speak("Page $currentPage");
                                          }
                                        : null,
                                    icon: Icon(Icons.chevron_left, size: 18),
                                    label: Text('Previous'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: currentPage > 1 ? Colors.pinkAccent : Colors.grey,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  ..._buildPageNumbers(),
                                  SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: currentPage < ((schemes.length - 1) ~/ 10) + 1
                                        ? () async {
                                            setState(() {
                                              currentPage++;
                                            });
                                            await _speak("Page $currentPage");
                                          }
                                        : null,
                                    icon: Icon(Icons.chevron_right, size: 18),
                                    label: Text('Next'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: currentPage < ((schemes.length - 1) ~/ 10) + 1 ? Colors.pinkAccent : Colors.grey,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ] else ...[
                        Container(
                          height: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No schemes found',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try searching with different keywords',
                                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }

    List<Widget> _tabContents = [
      _buildHomeContent(),
      Center(child: Text(loc.supportComingSoon, style: TextStyle(fontSize: 18))),
      MySchemesPage(),
      MicroLoansPage(),
      CommunityPage(),
    ];

    return Scaffold(
      body: Container(
        color: Colors.white,
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: loc.home),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: loc.support),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: loc.profile),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: loc.microLoans),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: loc.community),
        ],
      ),
    );
  }
}
