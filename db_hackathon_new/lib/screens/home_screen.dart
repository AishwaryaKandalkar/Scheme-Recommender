import 'package:flutter/material.dart';
import './_home_screen_body.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  void logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    print('Firestore profile: ${doc.data()}');
    return doc.data();
  }

  Future<List<dynamic>?> fetchSchemes(Map<String, dynamic> profile, BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    String mapIncome(dynamic income) {
      if (income == null) return '';
      double val = double.tryParse(income.toString().replaceAll(',', '')) ?? 0;
      if (val < 100000) return loc.incomeGroup1Lakh;
      if (val < 200000) return loc.incomeGroup1to2Lakh;
      if (val < 500000) return loc.incomeGroup2to5Lakh;
      if (val < 1000000) return loc.incomeGroup5to10Lakh;
      return loc.incomeGroup10PlusLakh;
    }
    final data = {
      'age': profile['age'] ?? 30,
      'gender': profile['gender'] ?? loc.male,
      'social_category': profile['category'] ?? loc.general,
      'income_group': mapIncome(profile['annual_income']),
      'location': profile['location'] ?? loc.urban,
      'situation': profile['situation'] ?? loc.defaultSituation,
    };
    print('Sending to backend: $data');
    final url = Uri.parse('http://10.166.220.251:5000/recommend');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    print('Backend response: ${response.body}');
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result.containsKey('recommended_schemes')) {
        return result['recommended_schemes'];
      } else {
        print('Backend error/message: ${result['error'] ?? result['message']}');
        return [];
      }
    }
    print('HTTP error: ${response.statusCode}');
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreenBody();
  }
}