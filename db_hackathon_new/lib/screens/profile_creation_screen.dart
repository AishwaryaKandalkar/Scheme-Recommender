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
  bool? _hasBankAccount; // New field

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _incomeController = TextEditingController();
  final _savingsController = TextEditingController();
  String _gender = 'Male';
  String _category = 'General';

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _categories = ['General', 'OBC', 'SC', 'ST'];

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context)!;
      _speak(loc.welcomeProfileCreation);
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

  Future<void> _speak(String text) async {
    await _flutterTts?.speak(text);
  }

  Future<void> _startListening(TextEditingController controller, String fieldName) async {
    final loc = AppLocalizations.of(context)!;
    try {
      await _speak("${loc.pleaseSpeakField} $fieldName");
      final result = await _voiceChannel.invokeMethod('startListening');
      if (result != null && result.isNotEmpty) {
        setState(() {
          controller.text = result;
        });
        await _speak("${loc.youSaid} $result");
      }
    } catch (e) {
      await _speak(loc.voiceInputFailed);
    }
  }

  void _nextStep() {
    if (_currentStep == 3) {
      _submit();
    } else if (_formKey.currentState!.validate() || _currentStep == 2) {
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
    final loc = AppLocalizations.of(context)!;
    switch (_currentStep) {
      case 0:
        _speak(loc.step1Description);
        break;
      case 1:
        _speak(loc.step2Description);
        break;
      case 2:
        _speak(loc.step3Description);
        break;
    }
  }

  String _getStepDescription() {
    final loc = AppLocalizations.of(context)!;
    switch (_currentStep) {
      case 0:
        return loc.step1Description;
      case 1:
        return loc.step2Description;
      case 2:
        return loc.step3Description;
      default:
        return loc.profileCreation;
    }
  }

  void _submit() async {
    final loc = AppLocalizations.of(context)!;
    try {
      await _speak(loc.creatingAccountWait);

      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'uid': userCred.user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'annual_income': _incomeController.text.trim(),
        'savings': _savingsController.text.trim(),
        'gender': _gender,
        'category': _category,
        'has_bank_account': _hasBankAccount,
      });

      await _speak(loc.accountCreatedSuccess);
      if (_hasBankAccount == false) {
        Navigator.pushReplacementNamed(context, '/support');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      await _speak(loc.accountCreationFailed);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.error}: ${e.toString()}')));
    }
  }

  Widget _buildCardContent(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: children,
      ),
    );
  }

  Widget _styledTextField(TextEditingController controller, String label, IconData icon, Color fillColor, {bool isObscure = false, FormFieldValidator<String>? validator, String? voiceLabel}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        validator: validator,
        style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 16, fontFamily: 'Roboto'),
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
          suffixIcon: voiceLabel != null && !isObscure ? IconButton(
            icon: Icon(Icons.mic, color: Color(0xFF1A237E)),
            onPressed: () => _startListening(controller, voiceLabel),
          ) : null,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _styledDropdown(String value, List<String> items, String label, IconData icon, Color fillColor, ValueChanged<String?> onChanged, {String? voiceLabel}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              onChanged: onChanged,
              style: TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Roboto'),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.grey[600], fontSize: 16, fontFamily: 'Roboto'),
                prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
                ),
              ),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            ),
          ),
          if (voiceLabel != null) ...[
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.volume_up, color: Color(0xFF1A237E)),
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
        // Step 0: Personal Info
        _buildCardContent([
          _styledTextField(
            _nameController,
            loc.fullName,
            Icons.person_outline,
            Colors.white,
            validator: (val) => val!.isEmpty ? loc.enterFullName : null,
            voiceLabel: loc.fullNameVoice,
          ),
          _styledTextField(
            _emailController,
            loc.emailAddress,
            Icons.email_outlined,
            Colors.white,
            validator: (val) => val!.isEmpty ? loc.enterEmail : null,
            voiceLabel: loc.emailAddressVoice,
          ),
          _styledTextField(
            _passwordController,
            loc.password,
            Icons.lock_outline,
            Colors.white,
            isObscure: true,
            validator: (val) => val!.length < 6 ? loc.createPassword : null,
          ),
          _styledTextField(
            _confirmPasswordController,
            loc.confirmPassword,
            Icons.lock_outline,
            Colors.white,
            isObscure: true,
            validator: (val) => val != _passwordController.text ? loc.reenterPassword : null,
          ),
        ]),
        // Step 1: Financial & Occupational
        _buildCardContent([
          _styledTextField(_incomeController, loc.annualIncome, Icons.trending_up, Colors.white, voiceLabel: loc.annualIncomeVoice),
          _styledTextField(_savingsController, loc.savings, Icons.savings_outlined, Colors.white, voiceLabel: loc.savingsVoice),
        ]),
        // Step 2: Demographics & Social
        _buildCardContent([
          _styledDropdown(_gender, _genders, loc.gender, Icons.wc, Colors.white, 
            (val) => setState(() => _gender = val!), voiceLabel: "gender"),
          _styledDropdown(_category, _categories, loc.category, Icons.category_outlined, Colors.white, 
            (val) => setState(() => _category = val!), voiceLabel: "category"),
        ]),
        // Step 3: Bank Account
        _buildCardContent([
          Text(
            loc.doBankAccount,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text(loc.yes),
                selected: _hasBankAccount == true,
                onSelected: (_) => setState(() => _hasBankAccount = true),
              ),
              SizedBox(width: 16),
              ChoiceChip(
                label: Text(loc.no),
                selected: _hasBankAccount == false,
                onSelected: (_) => setState(() => _hasBankAccount = false),
              ),
            ],
          ),
          if (_hasBankAccount == false)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                loc.needBankAccountSupport,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
                textAlign: TextAlign.center,
              ),
            ),
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
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Register", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontFamily: 'Roboto')),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo and header
                  Column(
                    children: [
                      SizedBox(height: 8),
                      // Triangle logo (matching screenshot)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFF1A237E),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.change_history,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        loc.createFinWiseAccount,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                  // Stepper
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _stepCircle(0, "Personal\nInfo"),
                        _stepLine(),
                        _stepCircle(1, "Financial &\nOccupational"),
                        _stepLine(),
                        _stepCircle(2, "Demographics\n& Bank"),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
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
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _speak(loc.goingBack);
                                _prevStep();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios,
                                    size: 18,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    loc.back,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentStep == 3 && _hasBankAccount == null) {
                                _speak(loc.selectBankAccount);
                                return;
                              }
                              if (_currentStep == 3) {
                                _speak(loc.creatingAccount);
                              } else {
                                _speak(loc.movingNextStep);
                              }
                              _nextStep();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1A237E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentStep == 3 ? loc.finish : loc.next,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentStep == 3 ? Icons.check_circle_outline : Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom stepper widgets for screenshot style
  Widget _stepCircle(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isCompleted ? Color(0xFF1A237E) : Color(0xFFE0E0E0),
            border: Border.all(
              color: isActive || isCompleted ? Color(0xFF1A237E) : Color(0xFFE0E0E0),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted 
              ? Icon(Icons.check, color: Colors.white, size: 16)
              : Text(
                  "${step + 1}",
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive || isCompleted ? Color(0xFF1A237E) : Colors.black54,
              fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _stepLine() => Expanded(
    child: Container(
      height: 2, 
      margin: EdgeInsets.symmetric(horizontal: 4),
      color: Color(0xFFE0E0E0),
    ),
  );
}
