import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _incomeController = TextEditingController();
  final _savingsController = TextEditingController();
  String _gender = 'Male';
  String _category = 'General';

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _categories = ['General', 'OBC', 'SC', 'ST'];

  void _nextStep() {
    if (_currentStep == 2) {
      _submit();
    } else if (_formKey.currentState!.validate()) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submit() async {
    try {
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
      });

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
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

  Widget _styledTextField(TextEditingController controller, String label, IconData icon, Color fillColor, {bool isObscure = false, FormFieldValidator<String>? validator}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _styledDropdown(String value, List<String> items, String label, IconData icon, Color fillColor, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    List<Widget> _buildStepContent() {
      return [
        _buildCardContent([
          Icon(Icons.lock_outline, color: Colors.blue, size: 48),
          SizedBox(height: 12),
          Text(loc.welcomeMessage, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _styledTextField(_nameController, loc.name, Icons.account_circle_outlined, Colors.blue.shade50, validator: (val) => val!.isEmpty ? loc.nameRequired : null),
          _styledTextField(_emailController, loc.email, Icons.email_outlined, Colors.purple.shade50, validator: (val) => val!.isEmpty ? loc.emailRequired : null),
          _styledTextField(_passwordController, loc.password, Icons.lock_outline, Colors.orange.shade50, isObscure: true, validator: (val) => val!.length < 6 ? loc.passwordLength : null),
        ]),
        _buildCardContent([
          Icon(Icons.attach_money, color: Colors.green, size: 48),
          SizedBox(height: 12),
          Text(loc.yourFinances ?? 'Your Finances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _styledTextField(_incomeController, loc.annualIncome, Icons.trending_up, Colors.green.shade50),
          _styledTextField(_savingsController, loc.savings, Icons.savings_outlined, Colors.yellow.shade50),
        ]),
        _buildCardContent([
          Icon(Icons.people_alt, color: Colors.pink, size: 48),
          SizedBox(height: 12),
          Text(loc.aboutYou ?? 'About You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _styledDropdown(_gender, _genders, loc.gender, Icons.wc, Colors.pink.shade50, (val) => setState(() => _gender = val!)),
          _styledDropdown(_category, _categories, loc.category, Icons.category_outlined, Colors.deepPurple.shade50, (val) => setState(() => _category = val!)),
        ]),
      ];
    }

    final stepContent = _buildStepContent();

    return Scaffold(
      backgroundColor: Color(0xFFF4F6FD),
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
                          onPressed: _prevStep,
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios, size: 18, color: Colors.deepPurple),
                              SizedBox(width: 4),
                              Text(loc.back, style: TextStyle(color: Colors.deepPurple)),
                            ],
                          ),
                        ),
                      ElevatedButton(
                        onPressed: _nextStep,
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
            ),
          ),
        ),
      ),
    );
  }
}
