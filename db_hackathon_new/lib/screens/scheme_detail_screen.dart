import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SchemeDetailScreen extends StatefulWidget {
  final String schemeName;
  const SchemeDetailScreen({required this.schemeName});

  @override
  _SchemeDetailScreenState createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen> {
  final TextEditingController amountController = TextEditingController();
  DateTime? dueDate;
  String? amountError;
  bool registering = false;
  String? registerMsg;

  Future<void> registerForScheme() async {
    setState(() { registering = true; registerMsg = null; amountError = null; });
    final amount = amountController.text.trim();
    if (amount.isEmpty) {
      setState(() { amountError = 'Please enter an amount.'; registering = false; });
      return;
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() { registerMsg = 'Not logged in.'; registering = false; });
        return;
      }
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      final data = doc.data() ?? {};
      final mySchemes = List<Map<String, dynamic>>.from(data['my_schemes'] ?? []);
      // Avoid duplicate registration
      if (mySchemes.any((s) => s['scheme_name'] == widget.schemeName)) {
        setState(() { registerMsg = 'Already registered for this scheme.'; registering = false; });
        return;
      }
      final now = DateTime.now();
      mySchemes.add({
        'scheme_name': widget.schemeName,
        'registered_at': now.toIso8601String(),
        'amount': amount,
        'due_date': dueDate?.toIso8601String(),
      });
      await docRef.set({'my_schemes': mySchemes}, SetOptions(merge: true));
      setState(() { registerMsg = 'Registered successfully!'; registering = false; });
    } catch (e) {
      setState(() { registerMsg = 'Error: $e'; registering = false; });
    }
  }
  Future<void> launchUrlExternal(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
  String? summary;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSchemeInfo();
  }

  Future<void> fetchSchemeInfo() async {
    setState(() { loading = true; error = null; });
    try {
      // Try with original name
      String name = widget.schemeName;
      var url = Uri.parse(
        'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(name)}'
      );
      var response = await http.get(url);

      // If not found, try with 'scheme' appended
      if (response.statusCode != 200) {
        name = widget.schemeName + ' scheme';
        url = Uri.parse(
          'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(name)}'
        );
        response = await http.get(url);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          summary = data['extract'] ?? 'No summary found.';
          loading = false;
        });
      } else {
        setState(() {
          error = null;
          summary = null;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching info: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.schemeName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : error != null
                ? Text(error!, style: TextStyle(color: Colors.red))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (summary != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(summary!),
                        ),
                      if (summary == null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('No summary found for this scheme.', style: TextStyle(color: Colors.red)),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: Icon(Icons.open_in_new),
                              label: Text('Search on Google'),
                              onPressed: () {
                                final query = Uri.encodeComponent(widget.schemeName + ' scheme');
                                final url = 'https://www.google.com/search?q=$query';
                                launchUrlExternal(Uri.parse(url));
                              },
                            ),
                          ],
                        ),
                      SizedBox(height: 24),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount you want to pay',
                          border: OutlineInputBorder(),
                          errorText: amountError,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Next due date: '),
                          Text(dueDate == null ? 'Not set' : '${dueDate!.toLocal()}'.split(' ')[0]),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: dueDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                              );
                              if (picked != null) setState(() => dueDate = picked);
                            },
                            child: Text('Pick Date'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.how_to_reg),
                        label: registering ? Text('Registering...') : Text('Register for this scheme'),
                        onPressed: registering ? null : registerForScheme,
                      ),
                      if (registerMsg != null) ...[
                        SizedBox(height: 12),
                        Text(registerMsg!, style: TextStyle(color: registerMsg!.contains('success') ? Colors.green : Colors.red)),
                      ],
                    ],
                  ),
      ),
    );
  }
}
