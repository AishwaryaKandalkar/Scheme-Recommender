import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../providers/language_provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _suggestedLanguageCode;
  String? _region;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("Location service disabled");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      String? state = placemarks.first.administrativeArea;
      setState(() {
        _region = state;
        _suggestedLanguageCode = _mapStateToLanguage(state);
        _isLoading = false;
      });
    } catch (e) {
      print('Location detection failed: $e');
      setState(() => _isLoading = false);
    }
  }

  String? _mapStateToLanguage(String? state) {
    if (state == null) return null;
    state = state.toLowerCase();
    if (state.contains('maharashtra')) return 'mr';
    if (state.contains('uttar pradesh') || state.contains('bihar') || state.contains('delhi') || state.contains('madhya pradesh')) return 'hi';
    return 'en';
  }

  @override
  Widget build(BuildContext context) {
    final String targetRoute = ModalRoute.of(context)?.settings.arguments as String? ?? '/';

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
          child: _isLoading
              ? CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language, size: 50, color: Colors.blue),
                    SizedBox(height: 16),
                    Text("Select your preferred language",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    if (_suggestedLanguageCode != null)
                      Column(
                        children: [
                          Text("We detected your region: $_region"),
                          Text("Suggested Language:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          _confirmLangBtn(context, _suggestedLanguageCode!, targetRoute),
                          TextButton(
                            onPressed: () => setState(() => _suggestedLanguageCode = null),
                            child: Text("Choose manually"),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    if (_suggestedLanguageCode == null)
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _langBtn(context, 'English', 'en', targetRoute),
                          _langBtn(context, 'हिन्दी', 'hi', targetRoute),
                          _langBtn(context, 'मराठी', 'mr', targetRoute),
                        ],
                      ),
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

  Widget _confirmLangBtn(BuildContext context, String code, String targetRoute) {
    String label = {
      'en': 'English',
      'hi': 'हिन्दी',
      'mr': 'मराठी'
    }[code] ?? 'English';

    return ElevatedButton.icon(
      onPressed: () {
        Provider.of<LanguageProvider>(context, listen: false).setLanguage(code);
        Navigator.pushReplacementNamed(context, targetRoute);
      },
      icon: Icon(Icons.check_circle),
      label: Text("Continue with $label"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black87,
        elevation: 3,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
