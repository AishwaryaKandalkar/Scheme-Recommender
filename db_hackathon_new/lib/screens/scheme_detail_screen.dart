import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SchemeDetailScreen extends StatefulWidget {
  final String schemeName;

  SchemeDetailScreen({required this.schemeName});

  @override
  _SchemeDetailScreenState createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen> {
  Map<String, dynamic>? schemeData;
  bool loading = true;
  String? error;

  final TextEditingController amountController = TextEditingController();
  DateTime? dueDate;
  String? amountError;
  bool registering = false;
  String? registerMsg;

  @override
  void initState() {
    super.initState();
    fetchSchemeDetail();
  }

  Future<void> fetchSchemeDetail() async {
    final url = Uri.parse(
        'http://192.168.1.4:5000/scheme_detail?name=${Uri.encodeComponent(widget.schemeName)}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          schemeData = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          error = json.decode(response.body)['error'] ?? 'Unknown error';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load scheme: $e';
        loading = false;
      });
    }
  }

  Future<void> registerForScheme() async {
    setState(() {
      registering = true;
      registerMsg = null;
      amountError = null;
    });

    final amount = amountController.text.trim();
    if (amount.isEmpty) {
      setState(() {
        amountError = 'Please enter an amount.';
        registering = false;
      });
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          registerMsg = 'Not logged in.';
          registering = false;
        });
        return;
      }

      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      final data = doc.data() ?? {};
      final mySchemes = List<Map<String, dynamic>>.from(data['my_schemes'] ?? []);

      if (mySchemes.any((s) => s['scheme_name'] == widget.schemeName)) {
        setState(() {
          registerMsg = 'Already registered for this scheme.';
          registering = false;
        });
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

      setState(() {
        registerMsg = 'Registered successfully!';
        registering = false;
      });
    } catch (e) {
      setState(() {
        registerMsg = 'Error: $e';
        registering = false;
      });
    }
  }

  void _launchWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildDetail(String title, String? value) {
    if (value == null || value.isEmpty || value == "N/A") return SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black87),
          children: [
            TextSpan(text: "$title: ", style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schemeName),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetail("Goal", schemeData?["scheme_goal"]),
                      _buildDetail("Eligibility", schemeData?["eligibility"]),
                      _buildDetail("Benefits", schemeData?["benefits"]),
                      _buildDetail("Returns", schemeData?["total_returns"]),
                      _buildDetail("Duration", schemeData?["time_duration"]),
                      _buildDetail("Application Process", schemeData?["application_process"]),
                      _buildDetail("Documents Required", schemeData?["required_documents"]),
                      _buildDetail("Funding Agency", schemeData?["funding_agency"]),
                      _buildDetail("Contact Details", schemeData?["contact_details"]),
                      if (schemeData?["scheme_website"] != null &&
                          schemeData!["scheme_website"].toString().startsWith("http"))
                        GestureDetector(
                          onTap: () => _launchWebsite(schemeData!["scheme_website"]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Visit Official Website",
                              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      Divider(height: 32, thickness: 1.5),
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
                          Text(dueDate == null
                              ? 'Not set'
                              : '${dueDate!.toLocal()}'.split(' ')[0]),
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
                        label: registering
                            ? Text('Registering...')
                            : Text('Register for this Scheme'),
                        onPressed: registering ? null : registerForScheme,
                      ),
                      if (registerMsg != null) ...[
                        SizedBox(height: 12),
                        Text(
                          registerMsg!,
                          style: TextStyle(
                            color: registerMsg!.contains('success')
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
