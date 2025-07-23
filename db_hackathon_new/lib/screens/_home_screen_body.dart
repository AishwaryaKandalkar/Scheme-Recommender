import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'scheme_detail_screen.dart';
import 'account_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<Map<String, dynamic>?> _fetchProfile() async {
  final user = _auth.currentUser;
  if (user == null) return null;
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  return doc.data();
}

Future<List<dynamic>?> _fetchSchemes(Map<String, dynamic> profile) async {
  final url = Uri.parse('http://192.168.1.4:5000/recommend');
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
    // Automatically fetch eligible schemes on home page load
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
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
                child: Text(
                  'Recommended Schemes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: goalController,
                        decoration: InputDecoration(
                          hintText: 'Type your goal or need (optional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
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
                              await fetchSchemes(customGoal: goalController.text.isNotEmpty ? goalController.text : null);
                            },
                      icon: loading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.search),
                      label: loading ? Text('') : Text('Find'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
              Container(
                constraints: BoxConstraints(minHeight: 300),
                child: pageSchemes.isEmpty && !loading && error.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey, size: 48),
                            SizedBox(height: 10),
                            Text('No eligible recommendations found.', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      if ((scheme['scheme_goal'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.flag, color: Colors.green, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(child: Text('Goal: ${scheme['scheme_goal']}', style: TextStyle(fontSize: 16))),
                                          ],
                                        ),
                                      if ((scheme['benefits'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.thumb_up, color: Colors.blueAccent, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(child: Text('Benefits: ${scheme['benefits']}', style: TextStyle(fontSize: 16))),
                                          ],
                                        ),
                                      if ((scheme['total_returns'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.trending_up, color: Colors.purple, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(child: Text('Returns: ${scheme['total_returns']}', style: TextStyle(fontSize: 16))),
                                          ],
                                        ),
                                      if ((scheme['time_duration'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.timer, color: Colors.teal, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(child: Text('Duration: ${scheme['time_duration']}', style: TextStyle(fontSize: 16))),
                                          ],
                                        ),
                                      if ((scheme['scheme_website'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.link, color: Colors.indigo, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(child: Text('Website: ${scheme['scheme_website']}', style: TextStyle(fontSize: 16, color: Colors.indigo))),
                                          ],
                                        ),
                                      if ((scheme['similarity_score'] ?? '').toString().isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.score, color: Colors.deepOrange, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(child: Text('Match Score: ${scheme['similarity_score']?.toStringAsFixed(2) ?? ''}', style: TextStyle(fontSize: 16))),
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

    Widget _buildSupportContent() {
      return Center(child: Text('Support page coming soon!', style: TextStyle(fontSize: 18)));
    }
    Widget _buildProfileContent() {
      // Show AccountPage directly in the tab
      return AccountPage();
    }
    Widget _buildMicroLoansContent() {
      return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Micro Loans',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Small loans for big dreams',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.trending_up,
                    title: 'Approval Rate',
                    value: '94%',
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.schedule,
                    title: 'Avg. Processing',
                    value: '24hrs',
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.percent,
                    title: 'Interest Rate',
                    value: 'From 12%',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Loan Categories
            Text(
              'Loan Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildLoanCategory(
                  icon: Icons.business,
                  title: 'Business Loans',
                  subtitle: '₹10K - ₹5L',
                  description: 'For small business ventures',
                  color: Colors.purple,
                ),
                _buildLoanCategory(
                  icon: Icons.agriculture,
                  title: 'Agriculture Loans',
                  subtitle: '₹5K - ₹2L',
                  description: 'For farming activities',
                  color: Colors.green,
                ),
                _buildLoanCategory(
                  icon: Icons.school,
                  title: 'Education Loans',
                  subtitle: '₹15K - ₹3L',
                  description: 'For skill development',
                  color: Colors.blue,
                ),
                _buildLoanCategory(
                  icon: Icons.health_and_safety,
                  title: 'Healthcare Loans',
                  subtitle: '₹5K - ₹1L',
                  description: 'For medical emergencies',
                  color: Colors.red,
                ),
              ],
            ),
            SizedBox(height: 24),

            // Featured Micro Loan Schemes
            Text(
              'Featured Micro Loan Schemes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Column(
              children: [
                _buildLoanSchemeCard(
                  schemeName: 'Pradhan Mantri Mudra Yojana',
                  loanAmount: '₹10,000 - ₹10,00,000',
                  interestRate: '7.5% - 12%',
                  tenure: '5 Years',
                  description: 'Loans to non-corporate, non-farm small/micro enterprises',
                  eligibilityHighlights: ['No collateral required', 'For business activities', 'Income proof required'],
                ),
                SizedBox(height: 16),
                _buildLoanSchemeCard(
                  schemeName: 'Stand-Up India Scheme',
                  loanAmount: '₹10,00,000 - ₹1,00,00,000',
                  interestRate: '9% - 14%',
                  tenure: '7 Years',
                  description: 'Bank loans for SC/ST and women entrepreneurs',
                  eligibilityHighlights: ['For SC/ST/Women', '18-65 years age', 'First-time entrepreneur'],
                ),
                SizedBox(height: 16),
                _buildLoanSchemeCard(
                  schemeName: 'Kisan Credit Card',
                  loanAmount: '₹3,00,000',
                  interestRate: '4% (with subsidy)',
                  tenure: 'Revolving',
                  description: 'Short-term credit for agriculture and allied activities',
                  eligibilityHighlights: ['For farmers', 'Land ownership', 'Crop cultivation'],
                ),
                SizedBox(height: 16),
                _buildLoanSchemeCard(
                  schemeName: 'Mahila Udyam Nidhi Scheme',
                  loanAmount: '₹10,000 - ₹10,00,000',
                  interestRate: '0.5% - 1% above bank rate',
                  tenure: '10 Years',
                  description: 'Soft loan scheme for women entrepreneurs',
                  eligibilityHighlights: ['Women only', 'Above 18 years', 'Small scale industry'],
                ),
              ],
            ),
            SizedBox(height: 24),

            // Application Process
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'How to Apply',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildProcessStep('1', 'Choose Loan Type', 'Select the category that fits your needs'),
                  _buildProcessStep('2', 'Check Eligibility', 'Review requirements and ensure you qualify'),
                  _buildProcessStep('3', 'Prepare Documents', 'Gather required documents and forms'),
                  _buildProcessStep('4', 'Submit Application', 'Apply through bank/financial institution'),
                  _buildProcessStep('5', 'Get Approval', 'Receive funds after verification'),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Quick Apply Button
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Redirecting to loan application portal...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Find Suitable Loan Schemes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
    Widget _buildCommunityContent() {
      return Center(child: Text('Community page coming soon!', style: TextStyle(fontSize: 18)));
    }

    List<Widget> _tabContents = [
      _buildHomeContent(),
      _buildSupportContent(),
      _buildProfileContent(),
      _buildMicroLoansContent(),
      _buildCommunityContent(),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe3f0ff), Color(0xFFf7fbff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _tabContents[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'Support',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Micro Loans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoanCategory({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanSchemeCard({
    required String schemeName,
    required String loanAmount,
    required String interestRate,
    required String tenure,
    required String description,
    required List<String> eligibilityHighlights,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            schemeName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLoanDetail('Amount', loanAmount, Icons.monetization_on),
              ),
              Expanded(
                child: _buildLoanDetail('Interest', interestRate, Icons.percent),
              ),
              Expanded(
                child: _buildLoanDetail('Tenure', tenure, Icons.schedule),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Key Eligibility:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: eligibilityHighlights.map((highlight) => Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                highlight,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                ),
              ),
            )).toList(),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/scheme_detail', arguments: schemeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Learn More',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDetail(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessStep(String step, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
