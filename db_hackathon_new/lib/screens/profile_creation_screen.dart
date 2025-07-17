// profile_creation_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/step_indicator.dart';

class ProfileCreationScreen extends StatefulWidget {
  @override
  _ProfileCreationScreenState createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  int _currentStep = 0;

  // Controllers and values
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

  List<Widget> _buildStepContent() {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.blueAccent, size: 28),
              SizedBox(width: 8),
              Text('Let’s get to know you!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent)),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.account_circle_outlined),
              filled: true,
              fillColor: Colors.blue.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (val) => val!.isEmpty ? 'Name is required' : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              filled: true,
              fillColor: Colors.purple.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (val) => val!.isEmpty ? 'Email is required' : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              filled: true,
              fillColor: Colors.orange.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (val) => val!.length < 6 ? 'Min 6 characters' : null,
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Your Finances', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _incomeController,
            decoration: InputDecoration(
              labelText: 'Annual Income',
              prefixIcon: Icon(Icons.trending_up),
              filled: true,
              fillColor: Colors.green.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _savingsController,
            decoration: InputDecoration(
              labelText: 'Savings',
              prefixIcon: Icon(Icons.savings_outlined),
              filled: true,
              fillColor: Colors.yellow.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_alt, color: Colors.pink, size: 28),
              SizedBox(width: 8),
              Text('About You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.pink)),
            ],
          ),
          SizedBox(height: 16),
          DropdownButtonFormField(
            value: _gender,
            items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (val) => setState(() => _gender = val as String),
            decoration: InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(Icons.wc),
              filled: true,
              fillColor: Colors.pink.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: 12),
          DropdownButtonFormField(
            value: _category,
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => _category = val as String),
            decoration: InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined),
              filled: true,
              fillColor: Colors.deepPurple.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final stepContent = _buildStepContent();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7FAFE), Color(0xFFE1E6F9), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
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
                          children: const [
                            Icon(Icons.arrow_back_ios, size: 18, color: Colors.deepPurple),
                            SizedBox(width: 4),
                            Text('Back', style: TextStyle(color: Colors.deepPurple)),
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
                          Text(_currentStep == 2 ? 'Finish' : 'Next', style: const TextStyle(fontSize: 16)),
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
    );
  }
}
