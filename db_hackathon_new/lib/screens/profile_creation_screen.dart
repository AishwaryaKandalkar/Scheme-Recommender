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
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (val) => val!.isEmpty ? 'Name is required' : null,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (val) => val!.isEmpty ? 'Email is required' : null,
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
            validator: (val) => val!.length < 6 ? 'Min 6 characters' : null,
          ),
        ],
      ),
      Column(
        children: [
          TextFormField(
            controller: _incomeController,
            decoration: InputDecoration(labelText: 'Annual Income'),
          ),
          TextFormField(
            controller: _savingsController,
            decoration: InputDecoration(labelText: 'Savings'),
          ),
        ],
      ),
      Column(
        children: [
          DropdownButtonFormField(
            value: _gender,
            items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (val) => setState(() => _gender = val as String),
            decoration: InputDecoration(labelText: 'Gender'),
          ),
          DropdownButtonFormField(
            value: _category,
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => _category = val as String),
            decoration: InputDecoration(labelText: 'Category'),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final stepContent = _buildStepContent();

    return Scaffold(
      appBar: AppBar(title: Text('Create Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              StepIndicator(totalSteps: 3, currentStep: _currentStep),
              SizedBox(height: 24),
              Expanded(child: stepContent[_currentStep]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(onPressed: _prevStep, child: Text('Back')),
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(_currentStep == 2 ? 'Finish' : 'Next'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
