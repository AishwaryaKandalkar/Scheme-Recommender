import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in successfully!')),
      );
      // Redirect to HomeScreen after login
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7FAFE),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open, size: 60, color: Colors.blue),
                SizedBox(height: 16),
                Text("Login",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 24),

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 45),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Login"),
                ),
                SizedBox(height: 12),

                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  child: Text("Don’t have an account? Register",
                      style: TextStyle(color: Colors.blue)),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/chatbot'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 45),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Chatbot", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
