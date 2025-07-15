import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatelessWidget {
final _auth = FirebaseAuth.instance;


  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<Map<String, dynamic>?> _fetchProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    print(doc.data());
    return doc.data();
  }

  Future<List<dynamic>?> _fetchSchemes(Map<String, dynamic> profile) async {
    // Map Firestore profile to backend API format
    String _mapIncome(dynamic income) {
      if (income == null) return '';
      double val = double.tryParse(income.toString().replaceAll(',', '')) ?? 0;
      if (val < 100000) return '<1 Lakh';
      if (val < 200000) return '1-2 Lakh';
      if (val < 500000) return '2-5 Lakh';
      if (val < 1000000) return '5-10 Lakh';
      return '10+ Lakh';
    }
    final data = {
      'age': profile['age'] ?? 30,
      'gender': profile['gender'] ?? 'Male',
      'social_category': profile['category'] ?? 'General',
      'income_group': _mapIncome(profile['annual_income']),
      'location': profile['location'] ?? 'Urban',
      'situation': profile['situation'] ?? '',
    };
    final url = Uri.parse('http://10.78.91.251:5000/recommend');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['recommended_schemes'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data!;
          return FutureBuilder<List<dynamic>?>(
            future: _fetchSchemes(profile),
            builder: (context, schemeSnap) {
              if (!schemeSnap.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final schemes = schemeSnap.data!;
              return Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome, ${user?.email ?? 'User'}!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Here are your recommended schemes:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: schemes.isEmpty
                          ? Center(child: Text('No recommendations found.'))
                          : ListView.builder(
                              itemCount: schemes.length,
                              itemBuilder: (context, index) {
                                final scheme = schemes[index];
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
