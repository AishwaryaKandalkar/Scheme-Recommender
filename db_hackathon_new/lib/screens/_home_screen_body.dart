import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import '../gen_l10n/app_localizations.dart';

import 'scheme_detail_screen.dart';
import 'account_page.dart';
import 'my_schemes_page.dart';
import 'community_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<Map<String, dynamic>?> _fetchProfile() async {
  final user = _auth.currentUser;
  if (user == null) return null;
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  return doc.data();
}

Future<List<dynamic>?> _fetchSchemes(Map<String, dynamic> profile, String lang) async {
  final url = Uri.parse('http://10.166.220.251:5000/recommend');
  final payload = Map<String, dynamic>.from(profile);
  payload['lang'] = lang; // Pass language to backend

  final response = await http.post(
    url,
    body: jsonEncode(payload),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['recommended_schemes'] ?? [];
  }
  return null;
}

Future<List<dynamic>?> _fetchEligibleSchemes(Map<String, dynamic> profile) async {
  final url = Uri.parse('http://10.166.220.251:5000/eligible_schemes');
  final response = await http.post(
    url,
    body: jsonEncode(profile),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['eligible_schemes'] ?? [];
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

  // Voice feature fields
  FlutterTts? flutterTts;
  bool isListening = false;
  static const platform = MethodChannel('voice_channel');

  bool isAiSearch = false; // Track if current results are from AI search

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

    // Prepare payload for API call
    final payload = {
      'age': profile?['age']?.toString() ?? '',
      'gender': profile?['gender'] ?? '',
      'social_category': profile?['social_category'] ?? profile?['category'] ?? '',
      'income_group': profile?['income_group'] ?? profile?['annual_income'] ?? '',
      'location': profile?['location'] ?? '',
    };

    final lang = Localizations.localeOf(context).languageCode; 
    print(lang);// 'en', 'hi', 'mr'
    List<dynamic>? result;

    if (customGoal != null && customGoal.trim().isNotEmpty) {
      // User provided specific search text - use ML-powered recommendation
      setState(() {
        isAiSearch = true;
      });
      await _speak("Searching for schemes related to: $customGoal");
      payload['situation'] = customGoal;
      result = await _fetchSchemes(payload, lang);
    } else {
      // Initial load without search text - use fast rule-based filtering
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
      
      // Voice feedback based on results
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
    List<Widget> pageNumbers = [];
    
    // Show page numbers around current page
    int start = (currentPage - 2).clamp(1, totalPages);
    int end = (currentPage + 2).clamp(1, totalPages);
    
    // Ensure we show at least 5 pages when possible
    if (end - start < 4) {
      if (start == 1) {
        end = (start + 4).clamp(1, totalPages);
      } else if (end == totalPages) {
        start = (end - 4).clamp(1, totalPages);
      }
    }
    
    for (int i = start; i <= end; i++) {
      pageNumbers.add(
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                currentPage = i;
              });
              await _speak("Page $i");
            },
            child: Text('$i'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPage == i ? Colors.pinkAccent : Colors.grey[300],
              foregroundColor: currentPage == i ? Colors.white : Colors.black87,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size(40, 36),
            ),
          ),
        ),
      );
    }
    
    return pageNumbers;
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize FlutterTts
    flutterTts = FlutterTts();
    
    // Use optimized initial load
    fetchSchemes(); // This will use rule-based filtering for fast initial load
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("Welcome to Scheme Recommender! Loading your eligible schemes quickly.");
    });
  }

  @override
  void dispose() {
    goalController.dispose();
    flutterTts?.stop();
    super.dispose();
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 32),
                    Text(
                      loc.welcomeUser(userName ?? loc.user),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade400,
                      child: Text(
                        userName != null ? userName![0].toUpperCase() : '',
                        style: TextStyle(color: Colors.white),
                      ),
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
                              String searchText = goalController.text.trim();
                              if (searchText.isNotEmpty) {
                                // Voice feedback for AI-powered search
                                await _speak("Using AI to find the best schemes for: $searchText");
                              } else {
                                // Voice feedback for refreshing eligible schemes
                                await _speak("Refreshing your eligible schemes");
                              }
                              await fetchSchemes(customGoal: searchText.isNotEmpty ? searchText : null);
                            },
                      icon: loading
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : (goalController.text.trim().isNotEmpty
                              ? Icon(Icons.psychology, color: Colors.white)
                              : Icon(Icons.refresh, color: Colors.white)),
                      label: loading
                          ? Text('')
                          : (goalController.text.trim().isNotEmpty
                              ? Text('AI Search', style: TextStyle(color: Colors.white))
                              : Text('Refresh', style: TextStyle(color: Colors.white))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goalController.text.trim().isNotEmpty ? Colors.deepPurple : Colors.pinkAccent,
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
              
              // Search mode indicator
              if (schemes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isAiSearch ? Colors.deepPurple.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isAiSearch ? Colors.deepPurple : Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAiSearch ? Icons.psychology : Icons.filter_list,
                              size: 16,
                              color: isAiSearch ? Colors.deepPurple : Colors.blue,
                            ),
                            SizedBox(width: 4),
                            Text(
                              isAiSearch ? 'AI Recommendations' : 'Eligible Schemes',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isAiSearch ? Colors.deepPurple : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.volume_up, color: Colors.pinkAccent, size: 20),
                        onPressed: () {
                          String modeText = isAiSearch 
                              ? "Showing AI-powered recommendations based on your search" 
                              : "Showing schemes you're eligible for based on your profile";
                          _speak("$modeText. Found ${schemes.length} schemes.");
                        },
                      ),
                    ],
                  ),
                ),
              
              Container(
                color: Colors.transparent,
                child: GridView.builder(
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
                        final lang = Localizations.localeOf(context).languageCode; // 'en', 'hi', 'mr'
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SchemeDetailScreen(
                              schemeName: scheme['scheme_name'] ?? '',
                              lang: lang, // Pass the language to the detail screen
                            ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.auto_graph, color: Colors.pinkAccent, size: 28),
                              IconButton(
                                icon: Icon(Icons.volume_up, color: Colors.pinkAccent, size: 20),
                                onPressed: () {
                                  String schemeInfo = scheme['scheme_name'] ?? '';
                                  if (scheme['total_returns'] != null) {
                                    schemeInfo += '. Return: ${scheme['total_returns']}';
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
                    );
                  },
                ),
              ),
              
              // Pagination Controls
              if (schemes.isNotEmpty) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      // Page info and total schemes count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Page $currentPage of ${((schemes.length - 1) ~/ 10) + 1}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              Text(
                                '${schemes.length} schemes',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                              IconButton(
                                icon: Icon(Icons.volume_up, color: Colors.pinkAccent, size: 18),
                                onPressed: () {
                                  int totalPages = ((schemes.length - 1) ~/ 10) + 1;
                                  _speak("Page $currentPage of $totalPages. Total ${schemes.length} schemes found.");
                                },
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Pagination buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Previous button
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
                          // Page numbers (show current and adjacent pages)
                          ..._buildPageNumbers(),
                          SizedBox(width: 16),
                          // Next button
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
                ),
                SizedBox(height: 20),
              ],
            ],
          ),
        ),
      );
    }

    Widget _buildSupportContent() {
      return Center(child: Text('Support page coming soon!', style: TextStyle(fontSize: 18)));
    }
    Widget _buildProfileContent() {
      // Show AccountPage directly in the tab
      return AccountPage();
    }
    Widget _buildMicroLoansContent() {
      return Center(child: Text('Micro Loans page coming soon!', style: TextStyle(fontSize: 18)));
    }
    Widget _buildCommunityContent() {
      return Center(child: Text('Community page coming soon!', style: TextStyle(fontSize: 18)));
    }

    List<Widget> _tabContents = [
      _buildHomeContent(),
      Center(child: Text(loc.supportComingSoon, style: TextStyle(fontSize: 18))),
      MySchemesPage(),
      Center(child: Text(loc.microLoansComingSoon, style: TextStyle(fontSize: 18))),
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
