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
  static const darkBlue = Color(0xFF1A237E);
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: Text(
          "Language Selection",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.volume_up, color: Colors.white),
              onPressed: () => _speak("Welcome to Scheme Recommender. Please select your preferred language to continue.", 'en'),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [darkBlue, darkBlue.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.all(20),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, darkBlue.withOpacity(0.02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: darkBlue.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: darkBlue.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(darkBlue),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Detecting your location...",
                          style: TextStyle(
                            fontSize: 16,
                            color: darkBlue,
                            fontFamily: 'Mulish',
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Language Icon and Title
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.language, size: 32, color: darkBlue),
                            SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: darkBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.volume_up, color: darkBlue, size: 18),
                                onPressed: () => _speak("Language Selection", 'en'),
                                padding: EdgeInsets.all(6),
                                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Main Title
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: darkBlue.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                "Select your preferred language",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkBlue,
                                  fontFamily: 'Roboto',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: darkBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.volume_up, color: darkBlue, size: 14),
                                onPressed: () => _speak("Select your preferred language", 'en'),
                                padding: EdgeInsets.all(4),
                                constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Region Detection and Language Options
                      if (_suggestedLanguageCode != null)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [darkBlue.withOpacity(0.05), Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: darkBlue.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              // Location detected section
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: darkBlue.withOpacity(0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on, color: darkBlue, size: 20),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Detected region: $_region",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: darkBlue,
                                          fontFamily: 'Mulish',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: darkBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.volume_up, color: darkBlue, size: 14),
                                        onPressed: () => _speak("We detected your region: $_region", 'en'),
                                        padding: EdgeInsets.all(6),
                                        constraints: BoxConstraints(minWidth: 26, minHeight: 26),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              
                              // Suggested language section
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: darkBlue.withOpacity(0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.recommend, color: darkBlue, size: 20),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Suggested Language",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: darkBlue,
                                          fontFamily: 'Mulish',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: darkBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.volume_up, color: darkBlue, size: 14),
                                        onPressed: () => _speak("Suggested Language", 'en'),
                                        padding: EdgeInsets.all(6),
                                        constraints: BoxConstraints(minWidth: 26, minHeight: 26),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              
                              // Suggested language button
                              _buildSuggestedLanguageButton(_suggestedLanguageCode!, targetRoute),
                              SizedBox(height: 10),
                              
                              // Choose manually button
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    _speak("Showing manual language selection", 'en');
                                    setState(() => _suggestedLanguageCode = null);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: darkBlue.withOpacity(0.3)),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit, color: darkBlue, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        "Choose manually",
                                        style: TextStyle(
                                          color: darkBlue,
                                          fontFamily: 'Mulish',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: darkBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        padding: EdgeInsets.all(4),
                                        child: Icon(Icons.volume_up, size: 14, color: darkBlue),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Manual language selection
                      if (_suggestedLanguageCode == null)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: darkBlue.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildLanguageCard('English', 'en', targetRoute),
                                  SizedBox(width: 12),
                                  _buildLanguageCard('हिन्दी', 'hi', targetRoute),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  _buildLanguageCard('मराठी', 'mr', targetRoute),
                                  SizedBox(width: 12),
                                  _buildLanguageCard('తెలుగు', 'te', targetRoute),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  _buildLanguageCard('தமிழ்', 'ta', targetRoute),
                                  SizedBox(width: 12),
                                  _buildLanguageCard('ગુજરાતી', 'gu', targetRoute),
                                ],
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedLanguageButton(String code, String targetRoute) {
    String languageName = _getLanguageDisplayName(code);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkBlue, darkBlue.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _setLanguage(code, languageName, targetRoute),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(
              languageName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.volume_up, color: Colors.white, size: 16),
                onPressed: () => _speak(languageName, code),
                padding: EdgeInsets.all(6),
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(String language, String code, String targetRoute) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, darkBlue.withOpacity(0.03)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: darkBlue.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: darkBlue.withOpacity(0.08),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _setLanguage(code, language, targetRoute),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: darkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.translate,
                    color: darkBlue,
                    size: 16,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  language,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                    fontFamily: 'Mulish',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: darkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.volume_up, color: darkBlue, size: 12),
                    onPressed: () => _speak(language, code),
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'hi': return 'हिन्दी';
      case 'mr': return 'मराठी';
      case 'te': return 'తెలుగు';
      case 'ta': return 'தமிழ்';
      case 'gu': return 'ગુજરાતી';
      default: return 'English';
    }
  }

  void _setLanguage(String code, String language, String targetRoute) {
    _speak("Selected $language", code);
    Provider.of<LanguageProvider>(context, listen: false).setLanguage(code);
    Navigator.pushReplacementNamed(context, targetRoute);
  }

}
