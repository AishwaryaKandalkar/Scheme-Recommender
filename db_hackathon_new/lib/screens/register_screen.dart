import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _incomeController = TextEditingController();
  final _savingsController = TextEditingController();

  String _gender = 'Male';
  String _category = 'General';

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _categories = ['General', 'OBC', 'SC', 'ST'];

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCred = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        await _firestore.collection('users').doc(userCred.user!.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'annual_income': _incomeController.text.trim(),
          'savings': _savingsController.text.trim(),
          'gender': _gender,
          'category': _category,
          'uid': userCred.user!.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registered Successfully')));
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Name'), validator: (val) => val!.isEmpty ? 'Required' : null),
              TextFormField(controller: _emailController, decoration: InputDecoration(labelText: 'Email'), validator: (val) => val!.isEmpty ? 'Required' : null),
              TextFormField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true, validator: (val) => val!.length < 6 ? 'Min 6 chars' : null),
              TextFormField(controller: _incomeController, decoration: InputDecoration(labelText: 'Annual Income')),
              TextFormField(controller: _savingsController, decoration: InputDecoration(labelText: 'Savings')),
              DropdownButtonFormField(
                value: _gender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => _gender = val as String),
              ),
              DropdownButtonFormField(
                value: _category,
                decoration: InputDecoration(labelText: 'Category'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _category = val as String),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: Text('Register')),
            ],
          ),
        ),
      ),
    );
  }
}
