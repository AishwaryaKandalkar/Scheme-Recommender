import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final url = Uri.parse('http://192.168.1.8:5000/recommend');
  print('Sending profile to backend: ${jsonEncode(profile)}');
  final response = await http.post(url, body: jsonEncode(profile), headers: {'Content-Type': 'application/json'});
  print('Backend response status: ${response.statusCode}');
  print('Backend response body: ${response.body}');
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

  Future<void> fetchSchemes() async {
    setState(() {
      loading = true;
      error = '';
    });
    final userProfile = await _fetchProfile();
    profile = userProfile;
    if (profile == null) {
      setState(() {
        loading = false;
        error = 'User profile not found.';
      });
      return;
    }
    final payload = {
      'situation': goalController.text.isNotEmpty ? goalController.text : (profile?['situation'] ?? 'Looking for investment schemes'),
      'income_group': profile?['income_group'] ?? profile?['annual_income'] ?? '',
      'social_category': profile?['social_category'] ?? profile?['category'] ?? '',
      'gender': profile?['gender'] ?? '',
      'age': profile?['age']?.toString() ?? '',
      'location': profile?['location'] ?? '',
    };
    print('Sending payload to backend: ${jsonEncode(payload)}');
    final result = await _fetchSchemes(payload);
    if (result != null) {
      schemes = result;
    } else {
      error = 'No data received from backend.';
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (schemes.length / 10).ceil();
    int startIdx = (currentPage - 1) * 10;
    int endIdx = (startIdx + 10).clamp(0, schemes.length);
    List<dynamic> pageSchemes = schemes.sublist(startIdx, endIdx);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text('Welcome', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black87),
            tooltip: 'Edit Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Color(0xFFF7F9FB),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Describe your problem or goal:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: goalController,
                      decoration: InputDecoration(
                        hintText: 'What are you looking for?',
                        border: InputBorder.none,
                        icon: Icon(Icons.question_answer),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: loading ? null : () async {
                      currentPage = 1;
                      await fetchSchemes();
                    },
                    icon: loading
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.search),
                    label: loading ? Text('') : Text('Find'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error, style: TextStyle(color: Colors.red)),
              ),
            SizedBox(height: 18),
            Expanded(
              child: pageSchemes.isEmpty && !loading && error.isEmpty
                  ? Center(child: Text('No eligible recommendations found.'))
                  : ListView.builder(
                      itemCount: pageSchemes.length,
                      itemBuilder: (context, index) {
                        final scheme = pageSchemes[index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(scheme['scheme_name'] ?? '',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                SizedBox(height: 6),
                                Text('🎯 Goal: ${scheme['scheme_goal'] ?? ''}'),
                                Text('💡 Benefits: ${scheme['benefits'] ?? ''}'),
                                Text('📈 Returns: ${scheme['total_returns'] ?? ''}'),
                                Text('⏳ Duration: ${scheme['time_duration'] ?? ''}'),
                                Text('🔗 Website: ${scheme['scheme_website'] ?? ''}'),
                                Text('📊 Match Score: ${scheme['similarity_score']?.toStringAsFixed(2) ?? ''}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (pageSchemes.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: 12),
                  Row(
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
                            backgroundColor: currentPage == pageNum ? Colors.blue.shade50 : Colors.white,
                          ),
                          child: Text('$pageNum'),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 8),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
