import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../gen_l10n/app_localizations.dart';

class MySchemesPage extends StatefulWidget {
  const MySchemesPage({Key? key}) : super(key: key);

  @override
  State<MySchemesPage> createState() => _MySchemesPageState();
}

class _MySchemesPageState extends State<MySchemesPage> {
  FlutterTts? flutterTts;
  static const darkBlue = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context)!;
      _speak(loc.myProfilePageDescription);
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.myProfile,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
              color: darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(Icons.language, color: darkBlue),
              tooltip: loc.changeLanguage,
              onPressed: () => _showLanguageDialog(context),
            ),
          ),
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
              onPressed: () => _speak(loc.myProfilePageDescription),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(Icons.edit, color: darkBlue),
              tooltip: loc.editProfile,
              onPressed: () {
                _speak(loc.editProfile);
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(Icons.logout, color: darkBlue),
              tooltip: loc.logout,
              onPressed: () async {
                _speak(loc.loggingOut);
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
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
        child: FutureBuilder<Map<String, dynamic>?>(
          future: fetchUserProfile(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: darkBlue));
            }
            final user = userSnapshot.data;
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // User Info Card
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
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 35,
                            child: Text(
                              user?['name'] != null && user!['name'].isNotEmpty
                                  ? user['name'][0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?['name'] ?? loc.user,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                loc.activeMember,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
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
                            onPressed: () {
                              String userName = user?['name'] ?? loc.user;
                              _speak(loc.profileUserInfo(userName));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Contact Info Card
                  Container(
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: darkBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(Icons.contact_page, color: darkBlue, size: 24),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.contactInformation,
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
                                icon: Icon(Icons.volume_up, color: darkBlue, size: 20),
                                onPressed: () {
                                  String email = user?['email'] ?? loc.noEmail;
                                  String phone = user?['phone'] ?? loc.noPhone;
                                  String location = user?['location'] ?? loc.noLocation;
                                  _speak(loc.contactInfoVoice(email, phone, location));
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildContactItem(Icons.email_outlined, user?['email'] ?? loc.noEmail, loc.email),
                        SizedBox(height: 12),
                        _buildContactItem(Icons.phone_outlined, user?['phone'] ?? loc.noPhone, loc.phone),
                        SizedBox(height: 12),
                        _buildContactItem(Icons.location_on_outlined, user?['location'] ?? loc.noLocation, loc.location),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
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
                          Container(
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
                            padding: EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: darkBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Icon(Icons.analytics, color: darkBlue, size: 24),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        loc.financialSummary,
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
                                        onPressed: () {
                                          _speak(loc.financialSummaryVoice(totalSavings, activeSchemes.toString(), investmentReturns, goalsAchieved));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _snapshotCard(
                                      icon: Icons.savings_outlined,
                                      title: loc.totalSavings,
                                      value: '₹$totalSavings',
                                      subtitle: loc.thisMonthGrowth,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 12),
                                    _snapshotCard(
                                      icon: Icons.assignment_turned_in_outlined,
                                      title: loc.activeSchemes,
                                      value: '$activeSchemes',
                                      subtitle: activeSchemes > 0 ? loc.joinedNewScheme('1') : loc.joinedNone,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _snapshotCard(
                                      icon: Icons.trending_up,
                                      title: loc.investmentReturns,
                                      value: '₹$investmentReturns',
                                      subtitle: loc.lastQuarterGrowth,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 12),
                                    _snapshotCard(
                                      icon: Icons.flag_outlined,
                                      title: loc.goalsAchieved,
                                      value: '$goalsAchieved',
                                      subtitle: loc.onTrackForMore,
                                      color: Colors.purple,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  // Schemes List
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(Icons.history, color: darkBlue, size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.recentActivitiesAndTips,
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
                          onPressed: () => _speak(loc.recentActivitiesVoice),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchMySchemes(),
                    builder: (context, snapshot) {
                      final schemes = snapshot.data ?? [];
                      if (schemes.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(24),
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
                          child: Column(
                            children: [
                              Icon(Icons.info_outline, size: 48, color: darkBlue.withOpacity(0.6)),
                              SizedBox(height: 16),
                              Text(
                                loc.noSchemesRegistered,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: darkBlue,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                loc.exploreNewSchemes,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontFamily: 'Mulish',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: darkBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.volume_up, color: darkBlue),
                                  onPressed: () => _speak(loc.noSchemesVoice),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: schemes.length,
                        itemBuilder: (context, index) {
                          final scheme = schemes[index];
                          final name = scheme['scheme_name'] ?? loc.unnamedScheme;
                          final amount = scheme['amount'];
                          final regDate = scheme['registered_at'] != null ? DateTime.tryParse(scheme['registered_at']) : null;
                          final dueDate = scheme['due_date'] != null ? DateTime.tryParse(scheme['due_date']) : null;

                          return Container(
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
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: darkBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Icon(Icons.account_balance_wallet, color: darkBlue, size: 24),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
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
                                        onPressed: () {
                                          String schemeInfo = "Scheme: $name";
                                          if (amount != null) schemeInfo += ". Amount: $amount rupees";
                                          if (regDate != null) schemeInfo += ". Registered on: ${regDate.toLocal().toString().split(' ')[0]}";
                                          if (dueDate != null) schemeInfo += ". Next due date: ${dueDate.toLocal().toString().split(' ')[0]}";
                                          _speak(schemeInfo);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    if (amount != null) ...[
                                      Expanded(
                                        child: _buildSchemeInfo(loc.amount, '₹$amount'),
                                      ),
                                    ],
                                    if (regDate != null) ...[
                                      if (amount != null) SizedBox(width: 12),
                                      Expanded(
                                        child: _buildSchemeInfo(loc.registered, '${regDate.toLocal().toString().split(' ')[0]}'),
                                      ),
                                    ],
                                  ],
                                ),
                                if (dueDate != null) ...[
                                  SizedBox(height: 12),
                                  _buildSchemeInfo(loc.nextDueDate, '${dueDate.toLocal().toString().split(' ')[0]}'),
                                ],
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
      ),
    );
  }

  Widget _snapshotCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final loc = AppLocalizations.of(context)!;
          _speak(loc.snapshotCardVoice(title, value, subtitle));
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: darkBlue,
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[600],
                  fontFamily: 'Mulish',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  icon: Icon(Icons.volume_up, color: color, size: 14),
                  onPressed: () {
                    final loc = AppLocalizations.of(context)!;
                    _speak(loc.snapshotCardVoice(title, value, subtitle));
                  },
                  padding: EdgeInsets.all(4),
                  constraints: BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeInfo(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: darkBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: darkBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkBlue,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String value, String label) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: darkBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: darkBlue, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Mulish',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                    fontFamily: 'Roboto',
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
              icon: Icon(Icons.volume_up, color: darkBlue, size: 16),
              onPressed: () {
                final loc = AppLocalizations.of(context)!;
                _speak(loc.contactItemVoice(label, value));
              },
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.selectLanguage),
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
        final loc = AppLocalizations.of(context)!;
        Provider.of<LanguageProvider>(context, listen: false).setLanguage(code);
        Navigator.of(context).pop();
        _speak(loc.languageSelected(label));
      },
    );
  }
}
