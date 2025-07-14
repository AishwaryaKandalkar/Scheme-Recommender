import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LocationAccessScreen extends StatefulWidget {
  @override
  State<LocationAccessScreen> createState() => _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen> {
  late String _targetRoute;

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
  }


  Future<void> _detectLocationAndProceed() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location permission denied")));
      return;
    }

    final Position position = await Geolocator.getCurrentPosition();
    String inferredLanguage = _inferLanguageFromLatLng(position.latitude, position.longitude);

    Provider.of<LanguageProvider>(context, listen: false).setLanguage(inferredLanguage);

    Navigator.pushNamed(context, '/language', arguments: _targetRoute);
  }

  void _skip() {
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
      body: Center(
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
              Icon(Icons.location_on, size: 60, color: Colors.blue),
              SizedBox(height: 16),
              Text("Welcome to Yogna Finance Guide",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text(
                "We need your location to suggest relevant financial schemes in your area",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _detectLocationAndProceed,
                child: Text("Allow Location Access"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 45)),
              ),
              SizedBox(height: 12),
              OutlinedButton(
                onPressed: _skip,
                child: Text("Skip and Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
