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

  double calculateProgress(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 0.0;
    final total = end.difference(start).inDays.toDouble();
    if (total <= 0) return 0.0;

    final passed = DateTime.now().difference(start).inDays.toDouble();
    return (passed / total).clamp(0.0, 1.0); // Keeps between 0.0 and 1.0
  }

  double estimateReturnGrowth(String? amountStr, double progressPercent) {
    if (amountStr == null) return 0.0;
    try {
      final amount = double.tryParse(amountStr) ?? 0.0;
      const yearlyGrowthRate = 0.08; // Assumed 8% return/year
      final growth = amount * yearlyGrowthRate * progressPercent;
      return double.parse(growth.toStringAsFixed(2));
    } catch (_) {
      return 0.0;
    }
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
              final name = scheme['scheme_name'] ?? 'Unnamed Scheme';
              final amount = scheme['amount'];
              final regDate = scheme['registered_at'] != null ? DateTime.tryParse(scheme['registered_at']) : null;
              final dueDate = scheme['due_date'] != null ? DateTime.tryParse(scheme['due_date']) : null;
              final reminder = getReminder(scheme);

              final progress = calculateProgress(regDate, dueDate);
              final estimatedGrowth = estimateReturnGrowth(amount?.toString(), progress);

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (amount != null) Text('Amount: ₹$amount'),
                      if (regDate != null)
                        Text('Registered on: ${regDate.toLocal().toString().split(' ')[0]}'),
                      if (dueDate != null)
                        Text('Next Due Date: ${dueDate.toLocal().toString().split(' ')[0]}'),
                      if (reminder != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            reminder,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 10),
                      Text('Progress toward due date'),
                      LinearProgressIndicator(
                        value: progress.isNaN || progress.isInfinite ? 0.0 : progress,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                        minHeight: 8,
                      ),
                      SizedBox(height: 8),
                      Text('Estimated Return Gained: ₹$estimatedGrowth'),
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
