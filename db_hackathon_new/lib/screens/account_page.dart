import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.edit),
              label: Text('Edit Profile'),
              onPressed: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.list_alt),
              label: Text('My Schemes'),
              onPressed: () {
                Navigator.pushNamed(context, '/my_schemes');
              },
            ),
          ],
        ),
      ),
    );
  }
}
