import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchAgents() async {
    final snapshot = await FirebaseFirestore.instance.collection('agents').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  void _callAgent(String phone) async {
    if (phone == null || phone.trim().isEmpty) {
      print('Phone number is empty');
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone.trim());
    print('Trying to launch: $uri');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $phone');
    }
  }

  void _messageAgent(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Support Hub')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAgents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final agents = snapshot.data!;
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              Text('Connect with a Local Agent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 12),
              ...agents.map((agent) => Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Text(
                              (agent['name'] ?? 'A').toString().split(' ').map((e) => e[0]).take(2).join(),
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(agent['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(agent['region'] ?? ''),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Availability: Mon-Fri 9AM - 5PM'), // You can store this in Firestore if needed
                      Text('Phone: ${agent['contact'] ?? ''}'),
                      Text('Email: ${agent['email'] ?? ''}'),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.call),
                            label: Text('Call Agent'),
                            onPressed: () => _callAgent(agent['contact'] ?? ''),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton.icon(
                            icon: Icon(Icons.email),
                            label: Text('Message Agent'),
                            onPressed: () => _messageAgent(agent['email'] ?? ''),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
              SizedBox(height: 24),
              Text('Bank Customer Care', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: Icon(Icons.account_balance),
                  title: Text('Bank Customer Care'),
                  subtitle: Text('+254 800 123 456\n24/7 Available'),
                  trailing: ElevatedButton(
                    child: Text('Call Now'),
                    onPressed: () => _callAgent('+254800123456'),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.account_balance),
                  title: Text('Bank Customer Care'),
                  subtitle: Text('+254 800 987 654\nMon-Fri, 8AM - 6PM'),
                  trailing: ElevatedButton(
                    child: Text('Call Now'),
                    onPressed: () => _callAgent('+254800987654'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}