import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgentRegisterScreen extends StatefulWidget {
  @override
  _AgentRegisterScreenState createState() => _AgentRegisterScreenState();
}

class _AgentRegisterScreenState extends State<AgentRegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String orgType = 'Individual';
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _regionController = TextEditingController();
  final _proofController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agent Registration')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: orgType,
                decoration: InputDecoration(labelText: 'Organization Type'),
                items: ['Individual', 'Organization']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => orgType = val ?? 'Individual'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Enter contact number' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _regionController,
                decoration: InputDecoration(labelText: 'Region'),
                validator: (v) => v == null || v.isEmpty ? 'Enter region' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _proofController,
                decoration: InputDecoration(labelText: 'Proof (ID/Document)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter proof' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(labelText: 'Agent ID'),
                validator: (v) => v == null || v.isEmpty ? 'Enter agent ID' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final agentId = _idController.text.trim();
                    final password = _passwordController.text.trim();
                    final email = agentId + '@agents.com';
                    try {
                      // Create agent in Firebase Auth
                      await _auth.createUserWithEmailAndPassword(email: email, password: password);
                      // Save agent info in Firestore
                      await _firestore.collection('agents').doc(agentId).set({
                        'orgType': orgType,
                        'name': _nameController.text.trim(),
                        'contact': _contactController.text.trim(),
                        'region': _regionController.text.trim(),
                        'proof': _proofController.text.trim(),
                        'agentId': agentId,
                        'email': email,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Agent registered successfully!')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registration failed: ' + e.toString())),
                      );
                    }
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
