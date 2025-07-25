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
import 'support_page.dart';
import 'micro_loans_page.dart';

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

Future<List<dynamic>?> _fetchSchemes(Map<String, dynamic> profile, String lang) async {
  final url = Uri.parse('http://10.146.241.105:5000/recommend');
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

Future<List<dynamic>?> _fetchEligibleSchemes(Map<String, dynamic> profile, String lang) async {
  final url = Uri.parse('http://10.146.241.105:5000/eligible_schemes');
  final payload = Map<String, dynamic>.from(profile);
  payload['lang'] = lang;
  final response = await http.post(
    url,
    body: jsonEncode(payload),
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
  static const darkBlue = Color(0xFF1A237E);
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
    final loc = AppLocalizations.of(context)!;
    setState(() {
      loading = true;
      error = '';
    });

    profile = await _fetchProfile();
    if (profile == null) {
      setState(() {
        loading = false;
        error = loc.userProfileNotFound;
      });
      return;
    }

    setState(() {
      userName = profile?['name'] ?? loc.user;
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
      await _speak(loc.searchingForSchemes(customGoal));
      payload['situation'] = customGoal;
      result = await _fetchSchemes(payload, lang);
    } else {
      // Initial load without search text - use fast rule-based filtering
      setState(() {
        isAiSearch = false;
      });
      await _speak(loc.loadingEligibleSchemes);
      result = await _fetchEligibleSchemes(payload, lang);
    }

    if (result != null) {
      setState(() {
        schemes = result!;
      });
      
      // Voice feedback based on results
      if (customGoal != null && customGoal.trim().isNotEmpty) {
        await _speak(loc.foundSchemesForSearch(result.length, customGoal));
      } else {
        await _speak(loc.loadedEligibleSchemes(result.length));
      }
    } else {
      setState(() {
        error = loc.noDataReceived;
      });
      await _speak(loc.failedToLoadSchemes);
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

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, color: darkBlue.withOpacity(0.7), size: 10),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[700],
                fontFamily: 'Mulish',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
    
    // Show fewer page numbers to prevent overflow
    int start = (currentPage - 1).clamp(1, totalPages);
    int end = (currentPage + 1).clamp(1, totalPages);
    
    // Ensure we show at least 3 pages when possible
    if (end - start < 2) {
      if (start == 1) {
        end = (start + 2).clamp(1, totalPages);
      } else if (end == totalPages) {
        start = (end - 2).clamp(1, totalPages);
      }
    }
    
    for (int i = start; i <= end; i++) {
      pageNumbers.add(
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            gradient: currentPage == i 
                ? LinearGradient(colors: [darkBlue, darkBlue.withOpacity(0.8)])
                : null,
            color: currentPage == i ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            onPressed: () async {
              final loc = AppLocalizations.of(context)!;
              setState(() {
                currentPage = i;
              });
              await _speak(loc.pageNumber(i));
            },
            child: Text(
              '$i',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: currentPage == i ? Colors.white : darkBlue,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size(36, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    
    // Use optimized initial load after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loc = AppLocalizations.of(context)!;
      await _speak(loc.welcomeToFinancialHub);
      // Load schemes after speaking welcome message
      await fetchSchemes(); // This will use rule-based filtering for fast initial load
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
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section with Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [darkBlue, darkBlue.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: darkBlue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.volume_up, color: Colors.white),
                            onPressed: () {
                              final loc = AppLocalizations.of(context)!;
                              _speak(loc.welcomeToFinancialHubDescription);
                            },
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              loc.welcomeUser(userName ?? loc.user),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 22,
                            child: Text(
                              userName != null ? userName![0].toUpperCase() : 'U',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      loc.discoverFinancialOpportunities,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontFamily: 'Mulish',
                      ),
                    ),
                  ],
                ),
              ),
              // Search Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: darkBlue.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: darkBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.search, color: darkBlue, size: 20),
                          ),
                          SizedBox(width: 12),
                          Text(
                            loc.findYourPerfectScheme,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: darkBlue.withOpacity(0.3)),
                              ),
                              child: TextFormField(
                                controller: goalController,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Mulish',
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  hintText: loc.whatAreYouLookingFor,
                                  hintStyle: TextStyle(
                                    fontFamily: 'Mulish', 
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.psychology, color: darkBlue.withOpacity(0.7), size: 20),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: darkBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            isListening ? Icons.mic : Icons.mic_none,
                                            color: isListening ? Colors.red : darkBlue,
                                            size: 16,
                                          ),
                                          onPressed: () => _listen(goalController),
                                          padding: EdgeInsets.all(6),
                                          constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: darkBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.volume_up, color: darkBlue, size: 16),
                                          onPressed: () {
                                            if (goalController.text.isNotEmpty) {
                                              _speak(goalController.text);
                                            }
                                          },
                                          padding: EdgeInsets.all(6),
                                          constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                ),
                                minLines: 1,
                                maxLines: 2,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: goalController.text.trim().isNotEmpty 
                                      ? [Colors.deepPurple, Colors.deepPurple.withOpacity(0.8)]
                                      : [darkBlue, darkBlue.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: (goalController.text.trim().isNotEmpty ? Colors.deepPurple : darkBlue).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: loading
                                    ? null
                                    : () async {
                                        final loc = AppLocalizations.of(context)!;
                                        currentPage = 1;
                                        String searchText = goalController.text.trim();
                                        if (searchText.isNotEmpty) {
                                          await _speak(loc.usingAiToFind(searchText));
                                        } else {
                                          await _speak(loc.refreshingEligibleSchemes);
                                        }
                                        await fetchSchemes(customGoal: searchText.isNotEmpty ? searchText : null);
                                      },
                                icon: loading
                                    ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : (goalController.text.trim().isNotEmpty
                                        ? Icon(Icons.psychology, color: Colors.white, size: 16)
                                        : Icon(Icons.refresh, color: Colors.white, size: 16)),
                                label: loading
                                    ? Text('')
                                    : (goalController.text.trim().isNotEmpty
                                        ? Text('')
                                        : Text('')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            error,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Mulish',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Search mode indicator
              if (schemes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: darkBlue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isAiSearch ? Colors.deepPurple : darkBlue).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isAiSearch ? Icons.psychology : Icons.filter_list,
                            size: 20,
                            color: isAiSearch ? Colors.deepPurple : darkBlue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAiSearch ? loc.aiRecommendations : loc.eligibleSchemes,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkBlue,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              Text(
                                loc.schemesFound(schemes.length),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontFamily: 'Mulish',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: darkBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.volume_up, color: darkBlue, size: 18),
                            onPressed: () {
                              final loc = AppLocalizations.of(context)!;
                              String modeText = isAiSearch 
                                  ? loc.showingAiRecommendations
                                  : loc.showingEligibleSchemes;
                              _speak(loc.foundSchemesTotal(modeText, schemes.length));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Schemes Grid
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: pageSchemes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final scheme = pageSchemes[index];
                    return GestureDetector(
                      onTap: () {
                        final lang = Localizations.localeOf(context).languageCode;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SchemeDetailScreen(
                              schemeName: scheme['scheme_name'] ?? '',
                              lang: lang,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: darkBlue.withOpacity(0.08),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: darkBlue.withOpacity(0.1)),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: darkBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.auto_graph, color: darkBlue, size: 18),
                                ),
                                Spacer(),
                                Container(
                                  decoration: BoxDecoration(
                                    color: darkBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.volume_up, color: darkBlue, size: 14),
                                    onPressed: () {
                                      String schemeInfo = scheme['scheme_name'] ?? '';
                                      if (scheme['total_returns'] != null) {
                                        schemeInfo += '. ${loc.returnLabel}: ${scheme['total_returns']}';
                                      }
                                      if (scheme['risk'] != null) {
                                        schemeInfo += '. ${loc.riskLabel}: ${scheme['risk']}';
                                      }
                                      if (scheme['time_duration'] != null) {
                                        schemeInfo += '. ${loc.termLabel}: ${scheme['time_duration']}';
                                      }
                                      _speak(schemeInfo);
                                    },
                                    padding: EdgeInsets.all(4),
                                    constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      scheme['scheme_name'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: darkBlue,
                                        fontFamily: 'Roboto',
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  if (scheme['total_returns'] != null)
                                    _buildDetailRow(Icons.trending_up, '${loc.returns}: ${scheme['total_returns']}'),
                                  if (scheme['risk'] != null)
                                    _buildDetailRow(Icons.security, '${loc.risk}: ${scheme['risk']}'),
                                  if (scheme['time_duration'] != null)
                                    _buildDetailRow(Icons.schedule, '${loc.term}: ${scheme['time_duration']}'),
                                ],
                              ),
                            ),
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
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: darkBlue.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Page info and total schemes count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.pageOf(currentPage, ((schemes.length - 1) ~/ 10) + 1),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkBlue,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${schemes.length} ${loc.schemes}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontFamily: 'Mulish',
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: darkBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.volume_up, color: darkBlue, size: 16),
                                  onPressed: () {
                                    int totalPages = ((schemes.length - 1) ~/ 10) + 1;
                                    _speak(loc.totalSchemesFound(currentPage, totalPages, schemes.length));
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Pagination buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Previous button
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: currentPage > 1 
                                      ? [darkBlue, darkBlue.withOpacity(0.8)]
                                      : [Colors.grey, Colors.grey.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: currentPage > 1
                                    ? () async {
                                        setState(() {
                                          currentPage--;
                                        });
                                        await _speak(loc.pageNumber(currentPage));
                                      }
                                    : null,
                                icon: Icon(Icons.chevron_left, size: 18),
                                label: Text(''),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            // Page numbers (show current and adjacent pages)
                            ..._buildPageNumbers(),
                            SizedBox(width: 8),
                            // Next button
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: currentPage < ((schemes.length - 1) ~/ 10) + 1
                                      ? [darkBlue, darkBlue.withOpacity(0.8)]
                                      : [Colors.grey, Colors.grey.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: currentPage < ((schemes.length - 1) ~/ 10) + 1
                                    ? () async {
                                        setState(() {
                                          currentPage++;
                                        });
                                        await _speak(loc.pageNumber(currentPage));
                                      }
                                    : null,
                                icon: Icon(Icons.chevron_right, size: 18),
                                label: Text(''),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
              ],
            ],
          ),
        ),
      );
    }

    List<Widget> _tabContents = [
      _buildHomeContent(),
      SupportPage(),
      MySchemesPage(),
      MicroLoansPage(),
      CommunityPage(),
    ];

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: _tabContents[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: darkBlue.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: darkBlue,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          selectedLabelStyle: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontFamily: 'Mulish'),
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
      ),
    );
  }
}
