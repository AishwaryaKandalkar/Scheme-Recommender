import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'investment_detail_screen.dart';

class SchemeDetailScreen extends StatelessWidget {
  final String schemeName;
  final String lang;

  const SchemeDetailScreen({Key? key, required this.schemeName, required this.lang}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SchemeDetailScreenState(schemeName: schemeName, lang: lang);
  }
}

class _SchemeDetailScreenState extends StatefulWidget {
  final String schemeName;
  final String lang;

  _SchemeDetailScreenState({required this.schemeName, required this.lang});

  @override
  __SchemeDetailScreenStateState createState() => __SchemeDetailScreenStateState();
}

class __SchemeDetailScreenStateState extends State<_SchemeDetailScreenState> {
  static const darkBlue = Color(0xFF1A237E);
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
    // Attempt to get user's location from their profile
    String userLocation = 'All';
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final doc = await docRef.get();
        final data = doc.data() ?? {};
        userLocation = data['location'] ?? 'All';
      }
    } catch (e) {
      print('Error fetching user location: $e');
    }
    
    final url = Uri.parse(
        'http://10.146.241.105:5000/scheme_detail?name=${Uri.encodeComponent(widget.schemeName)}&lang=${widget.lang}');

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
        'http://10.146.241.105:5000/predict_limits?scheme_name=${Uri.encodeComponent(widget.schemeName)}&lang=${widget.lang}');

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
      offset = Duration(days: 30);
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

      // Get user's location from their profile
      String? userLocation = data['location'] ?? 'All';
      
      mySchemes.add({
        'scheme_name': widget.schemeName,
        'registered_at': registrationDate!.toIso8601String(),
        'amount': amount,
        'due_date': dueDate!.toIso8601String(),
        'location': userLocation,
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
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: darkBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check_circle_outline, color: darkBlue, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: darkBlue,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontFamily: 'Mulish',
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.volume_up, color: darkBlue, size: 16),
              onPressed: () => _speak("$title: $value"),
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionInfo() {
    if (predictedAmount == null && predictedDuration == null) return SizedBox();

    final amtText = predictedAmount != null
        ? "₹${predictedAmount!.toStringAsFixed(0)} (±20%)"
        : null;

    final durationText =
        predictedDuration != null ? "$predictedDuration months" : null;

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkBlue.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: darkBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology, color: darkBlue, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                "AI Recommendations",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: darkBlue,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (amtText != null)
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: darkBlue.withOpacity(0.7), size: 16),
                SizedBox(width: 8),
                Text(
                  amtText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontFamily: 'Mulish',
                  ),
                ),
              ],
            ),
          SizedBox(height: 6),
          if (durationText != null)
            Row(
              children: [
                Icon(Icons.schedule, color: darkBlue.withOpacity(0.7), size: 16),
                SizedBox(width: 8),
                Text(
                  durationText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontFamily: 'Mulish',
                  ),
                ),
              ],
            ),
          SizedBox(height: 8),
          Text(
            "These suggestions are generated using advanced AI/ML algorithms.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
              fontFamily: 'Mulish',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: Text(
          "Scheme Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.volume_up, color: Colors.white),
              onPressed: () => _speakSchemeDetails(),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.help_outline, color: Colors.white),
              onPressed: () => _speak("This screen shows detailed information about ${widget.schemeName}. You can listen to any section by tapping the speaker icon next to it, and register for the scheme at the bottom."),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [darkBlue, darkBlue.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: loading
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(darkBlue),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Loading scheme details...",
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 16,
                        fontFamily: 'Mulish',
                      ),
                    ),
                  ],
                ),
              ),
            )
          : error != null
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[50]!, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.all(24),
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48),
                          SizedBox(height: 16),
                          Text(
                            "Error Loading Scheme",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontFamily: 'Mulish',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[50]!, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scheme Header Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, darkBlue.withOpacity(0.05)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: darkBlue.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: darkBlue.withOpacity(0.1),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 24),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: darkBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Image.asset(
                                  'assets/images/scheme_illustration.jpg',
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  widget.schemeName,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: darkBlue,
                                    fontFamily: 'Roboto',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, color: Colors.orange, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      schemeData?["rating"] != null
                                          ? "${schemeData!["rating"]} (${schemeData!["reviews"] ?? "Reviewed"})"
                                          : "4.8 (2,134 Reviews)",
                                      style: TextStyle(
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Mulish',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              if (schemeData?["scheme_goal"] != null)
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    schemeData!["scheme_goal"],
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                      fontFamily: 'Mulish',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        // Overview & Benefits Section
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: darkBlue.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: darkBlue.withOpacity(0.08),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: darkBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.info_outline, color: darkBlue, size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Scheme Overview & Benefits",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: darkBlue,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                            ...[
                              _buildDetail("Guaranteed annual returns", schemeData?["total_returns"]),
                              _buildDetail("Eligibility", schemeData?["eligibility"]),
                              _buildDetail("Benefits", schemeData?["benefits"]),
                              _buildDetail("Duration", schemeData?["time_duration"]),
                              _buildDetail("Application Process", schemeData?["application_process"]),
                              _buildDetail("Documents Required", schemeData?["required_documents"]),
                              _buildDetail("Funding Agency", schemeData?["funding_agency"]),
                              _buildDetail("Contact Details", schemeData?["contact_details"]),
                            ],
                            if (schemeData?["scheme_website"] != null &&
                                schemeData!["scheme_website"].toString().startsWith("http"))
                              Container(
                                margin: EdgeInsets.only(top: 16),
                                child: InkWell(
                                  onTap: () => _launchWebsite(schemeData!["scheme_website"]),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [darkBlue, darkBlue.withOpacity(0.8)],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.language, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          "Visit Official Website",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        // AI Prediction Info
                        _buildPredictionInfo(),
                        SizedBox(height: 32),
                        // Registration Form Section
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: darkBlue.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: darkBlue.withOpacity(0.08),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: darkBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.how_to_reg, color: darkBlue, size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Registration Form",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: darkBlue,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: darkBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.volume_up, color: darkBlue, size: 16),
                                      onPressed: () => _speak("Registration form. Enter your investment amount, select a registration date, and click register to join this scheme."),
                                      padding: EdgeInsets.all(8),
                                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: darkBlue.withOpacity(0.2)),
                                ),
                                child: TextField(
                                  controller: amountController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: darkBlue,
                                    fontFamily: 'Mulish',
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Investment Amount (₹)',
                                    labelStyle: TextStyle(
                                      color: darkBlue.withOpacity(0.7),
                                      fontFamily: 'Mulish',
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(20),
                                    errorText: amountError,
                                    errorStyle: TextStyle(fontFamily: 'Mulish'),
                                    prefixIcon: Container(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(Icons.currency_rupee, color: darkBlue.withOpacity(0.7), size: 20),
                                    ),
                                    suffixIcon: Container(
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: darkBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.mic, color: darkBlue, size: 18),
                                        onPressed: _startListening,
                                      ),
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
                              ),
                              if (showAmountWarning)
                                Container(
                                  margin: EdgeInsets.only(top: 12),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'This amount is outside the recommended range.',
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontFamily: 'Mulish',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(height: 20),
                              // Date Selection
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: darkBlue.withOpacity(0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_month, color: darkBlue.withOpacity(0.7), size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Registration Date:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: darkBlue,
                                            fontFamily: 'Mulish',
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: darkBlue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.volume_up, color: darkBlue, size: 16),
                                            onPressed: () {
                                              if (registrationDate != null) {
                                                _speak("Registration date is set to ${registrationDate!.day}-${registrationDate!.month}-${registrationDate!.year}");
                                              } else {
                                                _speak("No registration date selected yet. Please pick a date.");
                                              }
                                            },
                                            padding: EdgeInsets.all(8),
                                            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            registrationDate == null
                                                ? 'No date selected'
                                                : '${registrationDate!.day}/${registrationDate!.month}/${registrationDate!.year}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: registrationDate == null ? Colors.grey[600] : darkBlue,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [darkBlue, darkBlue.withOpacity(0.8)],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: ElevatedButton.icon(
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
                                            icon: Icon(Icons.date_range, color: Colors.white, size: 18),
                                            label: Text(
                                              'Select Date',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (dueDate != null) ...[
                                      SizedBox(height: 16),
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: darkBlue.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.schedule, color: darkBlue.withOpacity(0.7), size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              'Next due date: ',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: 'Mulish',
                                              ),
                                            ),
                                            Text(
                                              '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: darkBlue,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            Spacer(),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: darkBlue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.volume_up, color: darkBlue, size: 14),
                                                onPressed: () => _speak("Next due date is ${dueDate!.day}-${dueDate!.month}-${dueDate!.year}"),
                                                padding: EdgeInsets.all(6),
                                                constraints: BoxConstraints(minWidth: 26, minHeight: 26),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: 24),
                              // Register Button
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: registering 
                                        ? [Colors.grey, Colors.grey.withOpacity(0.8)]
                                        : [darkBlue, darkBlue.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: darkBlue.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  icon: registering 
                                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : Icon(Icons.how_to_reg, color: Colors.white),
                                  label: Text(
                                    registering ? 'Processing Registration...' : 'Register for this Scheme',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  onPressed: registering ? null : registerForScheme,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    padding: EdgeInsets.symmetric(vertical: 18),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Tap the register button to complete your registration",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontFamily: 'Mulish',
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: darkBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.volume_up, color: darkBlue, size: 16),
                                      onPressed: () => _speak("Tap the register button to complete your registration for ${widget.schemeName}"),
                                      padding: EdgeInsets.all(8),
                                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ),
                                ],
                              ),
                              if (registerMsg != null) ...[
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: registerMsg!.contains('success') 
                                        ? Colors.green[50] 
                                        : Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: registerMsg!.contains('success') 
                                          ? Colors.green.withOpacity(0.3) 
                                          : Colors.red.withOpacity(0.3)
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        registerMsg!.contains('success') ? Icons.check_circle : Icons.error,
                                        color: registerMsg!.contains('success') ? Colors.green : Colors.red,
                                        size: 24,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          registerMsg!,
                                          style: TextStyle(
                                            color: registerMsg!.contains('success') 
                                                ? Colors.green[700] 
                                                : Colors.red[700],
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Mulish',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: darkBlue.withOpacity(0.1)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Adjust Investment Amount",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: darkBlue,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      Text(
                                        "Maximum: ₹${predictedAmount?.toStringAsFixed(0) ?? "10,000"}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontFamily: 'Mulish',
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor: darkBlue,
                                          inactiveTrackColor: darkBlue.withOpacity(0.2),
                                          thumbColor: darkBlue,
                                          overlayColor: darkBlue.withOpacity(0.2),
                                        ),
                                        child: Slider(
                                          value: double.tryParse(amountController.text) ?? (predictedAmount ?? 10000),
                                          min: 0,
                                          max: predictedAmount ?? 10000,
                                          divisions: 100,
                                          label: "₹${amountController.text}",
                                          onChanged: (val) {
                                            setState(() {
                                              amountController.text = val.toStringAsFixed(0);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        // Similar Investment Opportunities
                        if (schemeData?['similar_investments'] != null &&
                            schemeData!['similar_investments'] is List) ...[
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: darkBlue.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: darkBlue.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: darkBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.trending_up, color: darkBlue, size: 20),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Similar Investment Opportunities',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: darkBlue,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  height: 160,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: schemeData!['similar_investments'].length,
                                    separatorBuilder: (context, index) => SizedBox(width: 16),
                                    itemBuilder: (context, index) {
                                      final sim = schemeData!['similar_investments'][index];
                                      final simName = sim['investment_name'] ?? 'Unnamed';
                                      final returns = sim['total_returns'] ?? 'N/A';
                                      final duration = sim['time_duration'] ?? 'N/A';
                                      return Container(
                                        width: 220,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.white, darkBlue.withOpacity(0.02)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(color: darkBlue.withOpacity(0.15)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: darkBlue.withOpacity(0.05),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: darkBlue.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(Icons.auto_graph, color: darkBlue, size: 16),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    simName,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: darkBlue,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Icon(Icons.trending_up, color: Colors.green, size: 14),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Returns: $returns",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                    fontFamily: 'Mulish',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.schedule, color: Colors.blue, size: 14),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Duration: $duration",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                    fontFamily: 'Mulish',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [darkBlue, darkBlue.withOpacity(0.8)],
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => InvestmentDetailScreen(investment: sim),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  "View Details",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Roboto',
                                                  ),
                                                ),
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
    );
  }
}
