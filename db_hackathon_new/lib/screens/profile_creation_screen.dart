import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import '../widgets/step_indicator.dart';
import '../gen_l10n/app_localizations.dart';

class ProfileCreationScreen extends StatefulWidget {
  @override
  _ProfileCreationScreenState createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  FlutterTts? _flutterTts;
  static const MethodChannel _voiceChannel = MethodChannel('voice_channel');

  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _incomeController = TextEditingController();
  final _savingsController = TextEditingController();
  String _gender = 'Male';
  String _category = 'General';
  bool _obscurePassword = true;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _categories = ['General', 'OBC', 'SC', 'ST'];

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("Welcome to profile creation. Let's set up your account in 3 simple steps.");
    });
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

  String? _validatePhone(String? value) {
    final loc = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return loc.phoneRequired;
    }
    
    // Remove any non-digit characters for validation
    String digits = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length != 10) {
      return loc.phoneValidation;
    }
    
    // Check if all characters are digits
    if (!RegExp(r'^\d{10}$').hasMatch(digits)) {
      return loc.phoneValidation;
    }
    
    return null;
  }

  Future<void> _speak(String text) async {
    await _flutterTts?.speak(text);
  }

  Future<void> _startListening(TextEditingController controller, String fieldName) async {
    try {
      await _speak("Please speak your $fieldName");
      final result = await _voiceChannel.invokeMethod('startListening');
      if (result != null && result.isNotEmpty) {
        setState(() {
          controller.text = result;
        });
        await _speak("You said: $result");
      }
    } catch (e) {
      await _speak("Voice input failed. Please type manually.");
    }
  }

  void _nextStep() {
    if (_currentStep == 2) {
      _submit();
    } else if (_formKey.currentState!.validate()) {
      setState(() => _currentStep++);
      _announceStep();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _announceStep();
    }
  }

  void _announceStep() {
    switch (_currentStep) {
      case 0:
        _speak("Step 1 of 3: Account Setup. Please enter your name, email, and password.");
        break;
      case 1:
        _speak("Step 2 of 3: Financial Information. Please enter your annual income and current savings.");
        break;
      case 2:
        _speak("Step 3 of 3: Personal Details. Please select your gender and category.");
        break;
    }
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return "Account Setup - Enter your personal credentials";
      case 1:
        return "Financial Information - Tell us about your finances";
      case 2:
        return "Personal Details - Complete your profile";
      default:
        return "Profile Creation";
    }
  }

  void _submit() async {
    try {
      await _speak("Creating your account, please wait...");
      
      // Create email from phone number for Firebase Auth
      String email = "${_phoneController.text.trim()}@phone.local";
      
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'uid': userCred.user!.uid,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': email, // Generated email for Firebase compatibility
        'annual_income': _incomeController.text.trim(),
        'savings': _savingsController.text.trim(),
        'gender': _gender,
        'category': _category,
      });

      await _speak("Account created successfully! Welcome to Scheme Recommender!");
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      await _speak("Account creation failed. Please try again.");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Widget _buildCardContent(List<Widget> children) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _styledTextField(TextEditingController controller, String label, IconData icon, Color fillColor, {bool isObscure = false, FormFieldValidator<String>? validator, String? voiceLabel, bool isPhone = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : isObscure,
        validator: validator,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPassword)
                IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.deepPurple,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                    _speak(_obscurePassword ? "Password hidden" : "Password visible");
                  },
                ),
              if (voiceLabel != null && !isPassword)
                IconButton(
                  icon: Icon(Icons.mic, color: Colors.deepPurple),
                  onPressed: () => _startListening(controller, voiceLabel),
                ),
            ],
          ),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _styledDropdown(String value, List<String> items, String label, IconData icon, Color fillColor, ValueChanged<String?> onChanged, {String? voiceLabel}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon),
                filled: true,
                fillColor: fillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            ),
          ),
          if (voiceLabel != null) ...[
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.volume_up, color: Colors.deepPurple),
              onPressed: () => _speak("Current $voiceLabel is $value. Available options are: ${items.join(', ')}"),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    List<Widget> _buildStepContent() {
      return [
        _buildCardContent([
          Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.blue, size: 48),
              Spacer(),
              IconButton(
                icon: Icon(Icons.volume_up, color: Colors.blue),
                onPressed: () => _speak("Step 1: Account Setup. Please enter your full name, phone number, and create a secure password of at least 6 characters."),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(loc.welcomeMessage, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _styledTextField(_nameController, loc.name, Icons.account_circle_outlined, Colors.blue.shade50, 
            validator: (val) => val!.isEmpty ? loc.nameRequired : null, voiceLabel: "full name"),
          _styledTextField(_phoneController, loc.phone, Icons.phone_outlined, Colors.purple.shade50, 
            validator: _validatePhone, voiceLabel: "phone number", isPhone: true),
          _styledTextField(_passwordController, loc.password, Icons.lock_outline, Colors.orange.shade50, 
            validator: (val) => val!.length < 6 ? loc.passwordLength : null, isPassword: true),
        ]),
        _buildCardContent([
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green, size: 48),
              Spacer(),
              IconButton(
                icon: Icon(Icons.volume_up, color: Colors.green),
                onPressed: () => _speak("Step 2: Financial Information. Please enter your annual income and current savings amount. This helps us recommend suitable schemes for you."),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(loc.yourFinances, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _styledTextField(_incomeController, loc.annualIncome, Icons.trending_up, Colors.green.shade50, voiceLabel: "annual income"),
          _styledTextField(_savingsController, loc.savings, Icons.savings_outlined, Colors.yellow.shade50, voiceLabel: "current savings"),
        ]),
        _buildCardContent([
          Row(
            children: [
              Icon(Icons.people_alt, color: Colors.pink, size: 48),
              Spacer(),
              IconButton(
                icon: Icon(Icons.volume_up, color: Colors.pink),
                onPressed: () => _speak("Step 3: Personal Details. Please select your gender and category. This information helps us provide targeted scheme recommendations."),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(loc.aboutYou, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _styledDropdown(_gender, _genders, loc.gender, Icons.wc, Colors.pink.shade50, 
            (val) => setState(() => _gender = val!), voiceLabel: "gender"),
          _styledDropdown(_category, _categories, loc.category, Icons.category_outlined, Colors.deepPurple.shade50, 
            (val) => setState(() => _category = val!), voiceLabel: "category"),
        ]),
      ];
    }

    final stepContent = _buildStepContent();

    return Scaffold(
      backgroundColor: Color(0xFFF4F6FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.deepPurple),
            onPressed: () => _speak("Profile Creation - Step ${_currentStep + 1} of 3. ${_getStepDescription()}"),
          ),
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.deepPurple),
            onPressed: () => _speak("This is a 3-step profile creation process. Fill in your account details, financial information, and personal details to get personalized scheme recommendations."),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StepIndicator(
                    totalSteps: 3,
                    currentStep: _currentStep,
                    activeColor: Colors.deepPurpleAccent,
                    inactiveColor: Colors.deepPurple.shade100,
                    dotSize: 16,
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                    child: Container(
                      key: ValueKey(_currentStep),
                      child: stepContent[_currentStep],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: () {
                            _speak("Going back to previous step");
                            _prevStep();
                          },
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios, size: 18, color: Colors.deepPurple),
                              SizedBox(width: 4),
                              Text(loc.back, style: TextStyle(color: Colors.deepPurple)),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          if (_currentStep < 2)
                            IconButton(
                              icon: Icon(Icons.volume_up, color: Colors.deepPurple),
                              onPressed: () => _speak("Tap next to continue to step ${_currentStep + 2}"),
                            ),
                          ElevatedButton(
                            onPressed: () {
                              if (_currentStep == 2) {
                                _speak("Creating your account");
                              } else {
                                _speak("Moving to next step");
                              }
                              _nextStep();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 2,
                            ),
                            child: Row(
                              children: [
                                Text(_currentStep == 2 ? loc.finish : loc.next, style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Icon(_currentStep == 2 ? Icons.check_circle_outline : Icons.arrow_forward_ios, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
