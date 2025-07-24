import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/language_provider.dart';

class LocationAccessScreen extends StatefulWidget {
  @override
  State<LocationAccessScreen> createState() => _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen> {
  late String _targetRoute;

  // Voice feature fields
  FlutterTts? flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
  }

  @override
  void dispose() {
    flutterTts?.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (flutterTts != null) {
      await flutterTts!.speak(text);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is String && args.startsWith('/')) {
      _targetRoute = args;
    } else {
      _targetRoute = '/'; // fallback route
    }

    print('✅ LocationAccessScreen targetRoute: $_targetRoute');
    
    // Announce the screen purpose after the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak("Welcome to Yogna Finance Guide. We need your location to suggest relevant financial schemes in your area. You can allow location access or skip to continue.");
    });
  }


  Future<void> _detectLocationAndProceed() async {
    _speak("Checking location services");
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      _speak("Location services are disabled. Opening location settings.");
      await Geolocator.openLocationSettings();
      return;
    }

    if (permission == LocationPermission.denied) {
      _speak("Requesting location permission");
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      _speak("Location permission denied. You can continue without location access.");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location permission denied")));
      return;
    }

    _speak("Getting your current location");
    final Position position = await Geolocator.getCurrentPosition();
    String inferredLanguage = _inferLanguageFromLatLng(position.latitude, position.longitude);

    _speak("Location detected successfully. Proceeding to language selection.");
    Provider.of<LanguageProvider>(context, listen: false).setLanguage(inferredLanguage);

    Navigator.pushNamed(context, '/language', arguments: _targetRoute);
  }

  void _skip() {
    _speak("Skipping location access. Proceeding to language selection.");
    Navigator.pushNamed(context, '/language', arguments: _targetRoute);
  }

  String _inferLanguageFromLatLng(double lat, double lon) {
    if (lat >= 28 && lat <= 30 && lon >= 76 && lon <= 78) {
      return 'hi'; // Delhi or nearby → Hindi
    } else if (lat >= 12 && lat <= 13 && lon >= 78 && lon <= 80) {
      return 'ta'; // Tamil Nadu
    } else {
      return 'en'; // Default
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.blue),
            onPressed: () => _speak("Welcome to Yogna Finance Guide. We need your location to suggest relevant financial schemes in your area. You can allow location access or skip to continue."),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 60, color: Colors.blue),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.volume_up, color: Colors.blue),
                    onPressed: () => _speak("Location access"),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text("Welcome to Yogna Finance Guide",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.volume_up, color: Colors.blue, size: 20),
                    onPressed: () => _speak("Welcome to Yogna Finance Guide"),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      "We need your location to suggest relevant financial schemes in your area",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.volume_up, color: Colors.blue, size: 16),
                    onPressed: () => _speak("We need your location to suggest relevant financial schemes in your area"),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _detectLocationAndProceed,
                      child: Text("Allow Location Access"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(double.infinity, 45)),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.volume_up, color: Colors.blue),
                    onPressed: () => _speak("Allow Location Access. This will help us suggest financial schemes relevant to your area."),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skip,
                      child: Text("Skip and Continue"),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.volume_up, color: Colors.blue),
                    onPressed: () => _speak("Skip and Continue. You can proceed without providing location access."),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
