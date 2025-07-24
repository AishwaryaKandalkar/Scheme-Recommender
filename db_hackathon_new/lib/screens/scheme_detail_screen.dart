import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

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
  FlutterTts? _flutterTts;
  static const MethodChannel _voiceChannel = MethodChannel('voice_channel');

  final TextEditingController amountController = TextEditingController();
  DateTime? registrationDate;
  DateTime? dueDate;
  String? amountError;
  bool registering = false;
  String? registerMsg;

  double? predictedAmount;
  int? predictedDuration;
  bool showAmountWarning = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    fetchSchemeDetail();
    fetchPrediction();
  }

  @override
  void dispose() {
    _flutterTts?.stop();
    super.dispose();
  }

  void _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts?.setLanguage("en-US");
    await _flutterTts?.setSpeechRate(0.5);
    await _flutterTts?.setVolume(1.0);
    await _flutterTts?.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts?.speak(text);
  }

  Future<void> _startListening() async {
    try {
      await _speak("Please speak the amount you want to pay");
      final result = await _voiceChannel.invokeMethod('startListening');
      if (result != null && result.isNotEmpty) {
        // Extract numbers from speech
        final RegExp numberRegex = RegExp(r'\d+');
        final matches = numberRegex.allMatches(result);
        if (matches.isNotEmpty) {
          final amount = matches.first.group(0);
          setState(() {
            amountController.text = amount ?? '';
          });
          await _speak("Amount set to $amount rupees");
        } else {
          await _speak("Could not understand the amount. Please try again.");
        }
      }
    } catch (e) {
      await _speak("Voice input failed. Please type manually.");
    }
  }

  void _speakSchemeDetails() {
    if (schemeData == null) return;
    
    String details = "Scheme Details for ${widget.schemeName}. ";
    
    if (schemeData!["scheme_goal"] != null) {
      details += "Goal: ${schemeData!["scheme_goal"]}. ";
    }
    
    if (schemeData!["benefits"] != null) {
      details += "Benefits: ${schemeData!["benefits"]}. ";
    }
    
    if (schemeData!["total_returns"] != null) {
      details += "Returns: ${schemeData!["total_returns"]}. ";
    }
    
    if (schemeData!["time_duration"] != null) {
      details += "Duration: ${schemeData!["time_duration"]}. ";
    }
    
    if (predictedAmount != null) {
      details += "AI suggests an amount of ${predictedAmount!.toStringAsFixed(0)} rupees. ";
    }
    
    _speak(details);
  }

  Future<void> fetchSchemeDetail() async {
    final url = Uri.parse(
        'http://10.166.220.251:5000/scheme_detail?name=${Uri.encodeComponent(widget.schemeName)}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          schemeData = json.decode(response.body);
          loading = false;
        });
        await _speak("Scheme details loaded successfully. ${widget.schemeName} information is now available.");
      } else {
        setState(() {
          error = json.decode(response.body)['error'] ?? 'Unknown error';
          loading = false;
        });
        await _speak("Failed to load scheme details. Please try again.");
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load scheme: $e';
        loading = false;
      });
      await _speak("Network error occurred while loading scheme details.");
    }
  }

  Future<void> fetchPrediction() async {
    final url = Uri.parse(
        'http://10.166.220.251:5000/predict_limits?scheme_name=${Uri.encodeComponent(widget.schemeName)}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          predictedAmount = (result['predicted_amount'] as num?)?.toDouble();
          predictedDuration = result['predicted_duration_months'];
        });

        if (amountController.text.trim().isEmpty && predictedAmount != null) {
          amountController.text = predictedAmount!.toStringAsFixed(0);
        }
      }
    } catch (e) {
      print("Prediction fetch failed: $e");
    }
  }

  void calculateDueDate() {
    if (registrationDate == null || schemeData == null) return;

    final interval = schemeData?['payment_interval']?.toLowerCase() ?? '';

    Duration offset;
    if (interval.contains('month')) {
      offset = Duration(days: 30);
    } else if (interval.contains('quarter')) {
      offset = Duration(days: 90);
    } else if (interval.contains('year')) {
      offset = Duration(days: 365);
    } else {
      offset = Duration(days: 30); // default to 1 month
    }

    setState(() {
      dueDate = registrationDate!.add(offset);
    });
  }

  Future<void> registerForScheme() async {
    setState(() {
      registering = true;
      registerMsg = null;
      amountError = null;
    });

    await _speak("Processing your registration...");

    final amount = amountController.text.trim();
    if (amount.isEmpty) {
      setState(() {
        amountError = 'Please enter an amount.';
        registering = false;
      });
      await _speak("Please enter an amount to continue.");
      return;
    }

    if (predictedAmount != null) {
      final entered = double.tryParse(amount);
      final lower = predictedAmount! * 0.8;
      final upper = predictedAmount! * 1.2;

      if (entered == null || entered < lower || entered > upper) {
        setState(() {
          amountError =
              'Amount must be within ±20% of ₹${predictedAmount!.toStringAsFixed(0)}';
          registering = false;
        });
        await _speak("Amount is outside the recommended range. Please adjust your amount.");
        return;
      }
    }

    if (registrationDate == null || dueDate == null) {
      setState(() {
        registerMsg = 'Please select a registration date.';
        registering = false;
      });
      await _speak("Please select a registration date first.");
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          registerMsg = 'Not logged in.';
          registering = false;
        });
        await _speak("You need to log in first.");
        return;
      }

      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      final data = doc.data() ?? {};
      final mySchemes =
          List<Map<String, dynamic>>.from(data['my_schemes'] ?? []);

      if (mySchemes.any((s) => s['scheme_name'] == widget.schemeName)) {
        setState(() {
          registerMsg = 'Already registered for this scheme.';
          registering = false;
        });
        await _speak("You are already registered for this scheme.");
        return;
      }

      mySchemes.add({
        'scheme_name': widget.schemeName,
        'registered_at': registrationDate!.toIso8601String(),
        'amount': amount,
        'due_date': dueDate!.toIso8601String(),
      });

      await docRef.set({'my_schemes': mySchemes}, SetOptions(merge: true));

      setState(() {
        registerMsg = 'Registered successfully!';
        registering = false;
      });
      await _speak("Congratulations! You have successfully registered for ${widget.schemeName} with amount $amount rupees.");
    } catch (e) {
      setState(() {
        registerMsg = 'Error: $e';
        registering = false;
      });
      await _speak("Registration failed due to an error. Please try again.");
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
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                      text: "$title: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.deepPurple, size: 18),
            onPressed: () => _speak("$title: $value"),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionInfo() {
    if (predictedAmount == null && predictedDuration == null) return SizedBox();

    final amtText = predictedAmount != null
        ? "💰 ₹${predictedAmount!.toStringAsFixed(0)} (±20%)"
        : null;

    final durationText =
        predictedDuration != null ? "⏳ $predictedDuration months" : null;

    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "🔍 Suggested by AI:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.volume_up, color: Colors.blue),
                onPressed: () {
                  String aiInfo = "AI Suggestions: ";
                  if (predictedAmount != null) {
                    aiInfo += "Recommended amount is ${predictedAmount!.toStringAsFixed(0)} rupees with 20 percent flexibility. ";
                  }
                  if (predictedDuration != null) {
                    aiInfo += "Expected duration is $predictedDuration months. ";
                  }
                  aiInfo += "These predictions are generated using artificial intelligence and machine learning.";
                  _speak(aiInfo);
                },
              ),
            ],
          ),
          if (amtText != null) Text(amtText),
          if (durationText != null) Text(durationText),
          Text("These are inferred from the scheme using AI/ML."),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schemeName),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: () => _speakSchemeDetails(),
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => _speak("This screen shows detailed information about ${widget.schemeName}. You can listen to any section by tapping the speaker icon next to it, and register for the scheme at the bottom."),
          ),
        ],
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
                      _buildDetail(
                          "Application Process", schemeData?["application_process"]),
                      _buildDetail(
                          "Documents Required", schemeData?["required_documents"]),
                      _buildDetail("Funding Agency", schemeData?["funding_agency"]),
                      _buildDetail("Contact Details", schemeData?["contact_details"]),
                      if (schemeData?["scheme_website"] != null &&
                          schemeData!["scheme_website"].toString().startsWith("http"))
                        GestureDetector(
                          onTap: () =>
                              _launchWebsite(schemeData!["scheme_website"]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Visit Official Website",
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      _buildPredictionInfo(),
                      if (schemeData?['similar_investments'] != null &&
                          schemeData!['similar_investments'] is List) ...[
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '📊 Similar Investments',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.volume_up, color: Colors.deepPurple),
                              onPressed: () {
                                final simList = schemeData!['similar_investments'] as List;
                                String similar = "Similar Investments: ";
                                for (var sim in simList) {
                                  final name = sim['investment_name'] ?? 'Unnamed';
                                  final returns = sim['total_returns'] ?? 'N/A';
                                  similar += "$name with returns $returns. ";
                                }
                                _speak(similar);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(schemeData!['similar_investments'].length, (index) {
                              final sim = schemeData!['similar_investments'][index];
                              final simName = sim['investment_name'] ?? 'Unnamed';
                              final returns = sim['total_returns'] ?? 'N/A';
                              final duration = sim['time_duration'] ?? 'N/A';

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SchemeDetailScreen(schemeName: simName),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 200,
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    border: Border.all(color: Colors.blueGrey.shade100),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(simName,
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.volume_up, color: Colors.grey.shade600, size: 16),
                                            onPressed: () => _speak("$simName. Returns: $returns. Duration: $duration"),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Text("Returns: $returns"),
                                      Text("Duration: $duration"),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                      Divider(height: 32, thickness: 1.5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Registration Form",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: Colors.deepPurple),
                            onPressed: () => _speak("Registration form. Enter your investment amount, select a registration date, and click register to join this scheme."),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount you want to pay',
                          border: OutlineInputBorder(),
                          errorText: amountError,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.mic, color: Colors.deepPurple),
                            onPressed: _startListening,
                          ),
                        ),
                        onChanged: (val) {
                          if (predictedAmount != null) {
                            final num? v = double.tryParse(val);
                            final lower = predictedAmount! * 0.8;
                            final upper = predictedAmount! * 1.2;
                            setState(() {
                              showAmountWarning =
                                  v != null && (v < lower || v > upper);
                            });
                          }
                        },
                      ),
                      if (showAmountWarning)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            '⚠️ This amount is outside the expected range.',
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                        ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Registration date: '),
                          Text(registrationDate == null
                              ? 'Not set'
                              : '${registrationDate!.toLocal()}'.split(' ')[0]),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await _speak("Opening date picker");
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: registrationDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                              );
                              if (picked != null) {
                                setState(() {
                                  registrationDate = picked;
                                });
                                calculateDueDate();
                                await _speak("Registration date set to ${picked.day}-${picked.month}-${picked.year}");
                              }
                            },
                            child: Text('Pick Date'),
                          ),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: Colors.deepPurple),
                            onPressed: () {
                              if (registrationDate != null) {
                                _speak("Registration date is set to ${registrationDate!.day}-${registrationDate!.month}-${registrationDate!.year}");
                              } else {
                                _speak("No registration date selected yet. Please pick a date.");
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (dueDate != null)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Next due date: ${dueDate!.toLocal()}'.split(' ')[0],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.volume_up, color: Colors.deepPurple),
                              onPressed: () => _speak("Next due date is ${dueDate!.day}-${dueDate!.month}-${dueDate!.year}"),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.how_to_reg),
                              label: registering
                                  ? Text('Registering...')
                                  : Text('Register for this Scheme'),
                              onPressed: registering ? null : registerForScheme,
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: Colors.deepPurple),
                            onPressed: () => _speak("Tap the register button to complete your registration for ${widget.schemeName}"),
                          ),
                        ],
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