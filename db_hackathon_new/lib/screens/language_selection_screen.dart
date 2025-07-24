import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/language_provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _suggestedLanguageCode;
  String? _region;
  bool _isLoading = true;

  // Voice feature fields
  FlutterTts? flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _detectLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("Welcome to Scheme Recommender. Please select your preferred language to continue.", 'en');
    });
  }

  @override
  void dispose() {
    flutterTts?.stop();
    super.dispose();
  }

  Future<void> _speak(String text, String languageCode) async {
    if (flutterTts != null) {
      await flutterTts!.setLanguage(_getLanguageLocale(languageCode));
      await flutterTts!.speak(text);
    }
  }

  String _getLanguageLocale(String code) {
    switch (code) {
      case 'hi':
        return 'hi-IN';
      case 'mr':
        return 'mr-IN';
      default:
        return 'en-US';
    }
  }

  String _getWelcomeMessage(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'स्कीम रेकमेंडर में आपका स्वागत है। कृपया जारी रखने के लिए अपनी पसंदीदा भाषा चुनें।';
      case 'mr':
        return 'स्कीम रेकमेंडरमध्ये आपले स्वागत आहे. कृपया सुरू ठेवण्यासाठी आपली पसंतीची भाषा निवडा.';
      default:
        return 'Welcome to Scheme Recommender. Please select your preferred language to continue.';
    }
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.blue),
            onPressed: () => _speak("Welcome to Scheme Recommender. Please select your preferred language to continue.", 'en'),
          ),
        ],
      ),
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
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Detecting your location..."),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.language, size: 50, color: Colors.blue),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.blue),
                          onPressed: () => _speak("Language Selection", 'en'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text("Select your preferred language",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.blue, size: 20),
                          onPressed: () => _speak("Select your preferred language", 'en'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (_suggestedLanguageCode != null)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(child: Text("We detected your region: $_region")),
                              IconButton(
                                icon: Icon(Icons.volume_up, color: Colors.blue, size: 16),
                                onPressed: () => _speak("We detected your region: $_region", 'en'),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text("Suggested Language:",
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                icon: Icon(Icons.volume_up, color: Colors.blue, size: 16),
                                onPressed: () => _speak("Suggested Language", 'en'),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          _confirmLangBtn(context, _suggestedLanguageCode!, targetRoute),
                          TextButton(
                            onPressed: () {
                              _speak("Showing manual language selection", 'en');
                              setState(() => _suggestedLanguageCode = null);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Choose manually"),
                                SizedBox(width: 4),
                                Icon(Icons.volume_up, size: 16, color: Colors.blue),
                              ],
                            ),
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
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _speak("Selected $label", code);
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
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: () => _speak(_getWelcomeMessage(code), code),
          child: Icon(Icons.volume_up, color: Colors.blue, size: 20),
        ),
      ],
    );
  }

  Widget _confirmLangBtn(BuildContext context, String code, String targetRoute) {
    String label = {
      'en': 'English',
      'hi': 'हिन्दी',
      'mr': 'मराठी'
    }[code] ?? 'English';

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _speak("Continuing with $label", code);
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
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _speak(_getWelcomeMessage(code), code),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up, color: Colors.blue, size: 20),
              SizedBox(width: 4),
              Text("Hear in $label", style: TextStyle(color: Colors.blue, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
