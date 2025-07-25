import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../gen_l10n/app_localizations.dart';

class SupportPage extends StatefulWidget {
  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  static const darkBlue = Color(0xFF1A237E);
  FlutterTts? flutterTts;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context)!;
      _speak(loc.supportHubWelcome);
    });
  }

  @override
  void dispose() {
    flutterTts?.stop();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (flutterTts != null) {
      await flutterTts!.speak(text);
    }
  }
  Future<List<Map<String, dynamic>>> fetchAgents() async {
    final snapshot = await FirebaseFirestore.instance.collection('agents').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  void _callAgent(String phone) async {
    if (phone.trim().isEmpty) return;
    final loc = AppLocalizations.of(context)!;
    await _speak(loc.calling(phone));
    final uri = Uri(scheme: 'tel', path: phone.trim());
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _messageAgent(String email) async {
    if (email.trim().isEmpty) return;
    final loc = AppLocalizations.of(context)!;
    await _speak(loc.openingEmail(email));
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.supportHub,
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: darkBlue.withOpacity(0.1),
        iconTheme: IconThemeData(color: darkBlue),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [darkBlue, darkBlue.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(Icons.volume_up, color: Colors.white),
              onPressed: () => _speak(loc.supportHubWelcome),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(Icons.help_outline, color: darkBlue),
              tooltip: loc.helpTooltip,
              onPressed: () => _speak(loc.getHelpSupport),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchAgents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: darkBlue),
              );
            }
            final agents = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [darkBlue, darkBlue.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: darkBlue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(Icons.support_agent, color: Colors.white, size: 28),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.howCanWeHelp,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    loc.searchKnowledgeBase,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontFamily: 'Mulish',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.volume_up, color: Colors.white),
                                onPressed: () => _speak("${loc.howCanWeHelp} ${loc.searchKnowledgeBase}"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: loc.searchHelpTopics,
                              hintStyle: TextStyle(fontFamily: 'Mulish'),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.search, color: darkBlue),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.volume_up, color: darkBlue, size: 20),
                                    onPressed: () {
                                      if (searchController.text.isNotEmpty) {
                                        _speak(searchController.text);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey, size: 20),
                                    onPressed: () {
                                      searchController.clear();
                                      _speak(loc.searchCleared);
                                    },
                                  ),
                                ],
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  // Local Agents Section
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(Icons.people, color: darkBlue, size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.connectWithLocalAgents,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: darkBlue,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.volume_up, color: darkBlue),
                          onPressed: () => _speak("${loc.connectWithLocalAgents}. ${loc.findExpertHelp}"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ...agents.map((agent) => Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: darkBlue.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [darkBlue.withOpacity(0.1), darkBlue.withOpacity(0.05)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  radius: 25,
                                  child: Text(
                                    (agent['name'] ?? 'A').toString().split(' ').map((e) => e[0]).take(2).join(),
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      agent['name'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: darkBlue,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    if (agent['region'] != null && agent['region'].toString().isNotEmpty)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          agent['region'],
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Mulish',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: darkBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.volume_up, color: darkBlue, size: 18),
                                  onPressed: () => _speak(loc.agentInfo(
                                    agent['name'] ?? '', 
                                    agent['region'] ?? loc.regionNotSpecified
                                  )),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: darkBlue.withOpacity(0.1)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.phone, color: darkBlue, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        agent['contact'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Mulish',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.email, color: darkBlue, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        agent['email'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Mulish',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [darkBlue, darkBlue.withOpacity(0.8)],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: darkBlue.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    icon: Icon(Icons.call, size: 18),
                                    label: Text(
                                      loc.call,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    onPressed: () => _callAgent(agent['contact'] ?? ''),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: darkBlue, width: 2),
                                  ),
                                  child: OutlinedButton.icon(
                                    icon: Icon(Icons.message, size: 18, color: darkBlue),
                                    label: Text(
                                      loc.message,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: darkBlue,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    onPressed: () => _messageAgent(agent['email'] ?? ''),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
                  SizedBox(height: 32),
                  // Bank Customer Care Section
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(Icons.account_balance, color: darkBlue, size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.bankCustomerCare,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: darkBlue,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.volume_up, color: darkBlue),
                          onPressed: () => _speak("${loc.bankCustomerCare}. ${loc.bankCustomerCareDescription}"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ...[
                    {
                      'title': loc.primaryCustomerCare,
                      'phone': '+254 800 123 456',
                      'subtitle': loc.primaryCustomerCareSubtitle,
                      'icon': Icons.support_agent,
                      'color': Colors.green,
                    },
                    {
                      'title': loc.technicalSupport,
                      'phone': '+254 800 987 654',
                      'subtitle': loc.technicalSupportSubtitle,
                      'icon': Icons.build,
                      'color': Colors.orange,
                    },
                  ].map((bank) => Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: darkBlue.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (bank['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  bank['icon'] as IconData,
                                  color: bank['color'] as Color,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (bank['title'] as String?) ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: darkBlue,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      (bank['phone'] as String?) ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                        fontFamily: 'Mulish',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      (bank['subtitle'] as String?) ?? '',
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
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.volume_up, color: darkBlue, size: 18),
                                  onPressed: () => _speak("${(bank['title'] as String?) ?? ''}: ${(bank['phone'] as String?) ?? ''}, ${(bank['subtitle'] as String?) ?? ''}"),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [darkBlue, darkBlue.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: darkBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.call, size: 20),
                              label: Text(
                                loc.callNow,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () => _callAgent((bank['phone'] as String?) ?? ''),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}