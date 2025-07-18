import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MySchemesPage extends StatelessWidget {
  const MySchemesPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchMySchemes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data == null || data['my_schemes'] == null) return [];
    return List<Map<String, dynamic>>.from(data['my_schemes']);
  }

  String? getReminder(Map<String, dynamic> scheme) {
    if (scheme['due_date'] == null) return null;
    try {
      final due = DateTime.parse(scheme['due_date']);
      final now = DateTime.now();
      if (due.year == now.year && due.month == now.month && due.day == now.day) {
        return 'Reminder: Today is the due date for this scheme!';
      } else if (due.isBefore(now)) {
        return 'Reminder: Due date has passed!';
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Schemes')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMySchemes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final schemes = snapshot.data ?? [];
          if (schemes.isEmpty) {
            return Center(child: Text('No schemes registered yet.'));
          }
          return ListView.builder(
            itemCount: schemes.length,
            itemBuilder: (context, index) {
              final scheme = schemes[index];
              final regDate = scheme['registered_at'] != null ? DateTime.tryParse(scheme['registered_at']) : null;
              final dueDate = scheme['due_date'] != null ? DateTime.tryParse(scheme['due_date']) : null;
              final reminder = getReminder(scheme);
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(scheme['scheme_name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (scheme['amount'] != null) Text('Amount: ₹${scheme['amount']}'),
                      if (regDate != null) Text('Registered on: ${regDate.toLocal().toString().split(' ')[0]}'),
                      if (dueDate != null) Text('Next Due Date: ${dueDate.toLocal().toString().split(' ')[0]}'),
                      if (reminder != null) Text(reminder, style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
