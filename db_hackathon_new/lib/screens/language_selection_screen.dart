import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String targetRoute = ModalRoute.of(context)?.settings.arguments as String? ?? '//';
    final languageProvider = Provider.of<LanguageProvider>(context);
    print('Navigating to $targetRoute');

    return Scaffold(
      backgroundColor: Color(0xFFF7FAFE),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 50, color: Colors.blue),
              SizedBox(height: 16),
              Text("Select your preferred language",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _langBtn(context, 'English', 'en', '/'),
                  _langBtn(context, 'हिन्दी', 'hi', '/'),
                  _langBtn(context, 'मराठी', 'mr', '/'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _langBtn(BuildContext context, String label, String code, String targetRoute) {
    return ElevatedButton(
      onPressed: () {
        Provider.of<LanguageProvider>(context, listen: false).setLanguage(code);
        Navigator.pushReplacementNamed(context, targetRoute);
      },
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
