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

// Use 10.0.2.2 for Android emulator, or your PC's IP for physical device
Future<List<dynamic>?> _fetchSchemes(Map<String, dynamic> profile) async {
  final url = Uri.parse('http://10.78.91.251:5000/recommend'); // Change to your PC IP if using a real device
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
  final TextEditingController ageController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController incomeGroupController = TextEditingController();
  final TextEditingController socialCategoryController = TextEditingController();
  int currentPage = 1;
  List<dynamic> schemes = [];
  bool loading = false;
  String error = '';
  Map<String, dynamic>? profile;

  Future<void> fetchSchemes() async {
    setState(() { loading = true; error = ''; });
    final userProfile = await _fetchProfile();
    profile = userProfile;
    // Prompt for missing fields
    String age = profile?['age']?.toString() ?? ageController.text;
    String location = profile?['location']?.toString() ?? locationController.text;
    String incomeGroup = profile?['income_group']?.toString() ?? profile?['annual_income']?.toString() ?? incomeGroupController.text;
    String socialCategory = profile?['social_category']?.toString() ?? profile?['category']?.toString() ?? socialCategoryController.text;

    if (age.isEmpty || location.isEmpty || incomeGroup.isEmpty || socialCategory.isEmpty) {
      setState(() { loading = false; error = 'Please fill all required fields.'; });
      return;
    }

    final payload = {
      'situation': goalController.text.isNotEmpty ? goalController.text : (profile?['situation'] ?? 'Looking for investment schemes'),
      'income_group': incomeGroup,
      'social_category': socialCategory,
      'gender': profile?['gender'] ?? '',
      'age': age,
      'location': location,
    };
    print('Sending payload to backend: ${jsonEncode(payload)}');
    final result = await _fetchSchemes(payload);
    if (result != null) {
      // Show all recommended schemes from backend
      schemes = result;
    } else {
      error = 'No data received from backend.';
    }
    setState(() { loading = false; });
  }

  @override
  void dispose() {
    goalController.dispose();
    ageController.dispose();
    locationController.dispose();
    incomeGroupController.dispose();
    socialCategoryController.dispose();
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
        title: Text('Welcome'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: goalController,
                    decoration: InputDecoration(
                      labelText: 'Describe your goal/problem',
                      prefixIcon: Icon(Icons.question_answer),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    currentPage = 1;
                    await fetchSchemes();
                  },
                  child: Text('Enter'),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.cake),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: incomeGroupController,
                    decoration: InputDecoration(
                      labelText: 'Income Group',
                      prefixIcon: Icon(Icons.money),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: socialCategoryController,
                    decoration: InputDecoration(
                      labelText: 'Social Category',
                      prefixIcon: Icon(Icons.group),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (loading)
              Center(child: CircularProgressIndicator()),
            if (error.isNotEmpty)
              Center(child: Text(error)),
            if (!loading && error.isEmpty)
              Expanded(
                child: pageSchemes.isEmpty
                    ? Center(child: Text('No eligible recommendations found.'))
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: pageSchemes.length,
                              itemBuilder: (context, index) {
                                final scheme = pageSchemes[index];
                                return Card(
                                  margin: EdgeInsets.all(10),
                                  child: ListTile(
                                    title: Text(scheme['scheme_name'] ?? ''),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Goal: ${scheme['scheme_goal'] ?? ''}'),
                                        Text('Benefits: ${scheme['benefits'] ?? ''}'),
                                        Text('Returns: ${scheme['total_returns'] ?? ''}'),
                                        Text('Duration: ${scheme['time_duration'] ?? ''}'),
                                        Text('Website: ${scheme['scheme_website'] ?? ''}'),
                                        Text('Score: ${scheme['similarity_score']?.toStringAsFixed(2) ?? ''}'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(totalPages, (i) {
                              final pageNum = i + 1;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() { currentPage = pageNum; });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: currentPage == pageNum ? Colors.blue.shade100 : null,
                                  ),
                                  child: Text('$pageNum'),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
