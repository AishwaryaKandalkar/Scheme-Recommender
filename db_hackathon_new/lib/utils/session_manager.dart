import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionManager {
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _loginTimestampKey = 'login_timestamp';
  static const String _rememberedEmailKey = 'remembered_email';
  static const String _rememberedPasswordKey = 'remembered_password';
  static const String _rememberMeKey = 'remember_me';

  // Check if user has an active session
  static Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    final timestamp = prefs.getInt(_loginTimestampKey);
    
    if (userId == null || timestamp == null) return false;
    
    // Check if session is less than 30 days old
    final sessionAge = DateTime.now().millisecondsSinceEpoch - timestamp;
    final thirtyDaysInMs = 30 * 24 * 60 * 60 * 1000;
    
    return sessionAge < thirtyDaysInMs;
  }

  // Get current session data
  static Future<Map<String, String?>> getSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'userEmail': prefs.getString(_userEmailKey),
      'loginTimestamp': prefs.getInt(_loginTimestampKey)?.toString(),
    };
  }

  // Save user session
  static Future<void> saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, user.uid);
    await prefs.setString(_userEmailKey, user.email ?? '');
    await prefs.setInt(_loginTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Clear user session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_loginTimestampKey);
  }

  // Save remembered credentials
  static Future<void> saveRememberedCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rememberedEmailKey, email);
    await prefs.setString(_rememberedPasswordKey, password);
    await prefs.setBool(_rememberMeKey, true);
  }

  // Get remembered credentials
  static Future<Map<String, String?>> getRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    
    if (!rememberMe) return {'email': null, 'password': null, 'rememberMe': 'false'};
    
    return {
      'email': prefs.getString(_rememberedEmailKey),
      'password': prefs.getString(_rememberedPasswordKey),
      'rememberMe': rememberMe.toString(),
    };
  }

  // Clear remembered credentials
  static Future<void> clearRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberedEmailKey);
    await prefs.remove(_rememberedPasswordKey);
    await prefs.setBool(_rememberMeKey, false);
  }

  // Get session duration in human readable format
  static Future<String> getSessionDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_loginTimestampKey);
    
    if (timestamp == null) return 'No active session';
    
    final duration = DateTime.now().millisecondsSinceEpoch - timestamp;
    final days = duration ~/ (24 * 60 * 60 * 1000);
    final hours = (duration % (24 * 60 * 60 * 1000)) ~/ (60 * 60 * 1000);
    final minutes = (duration % (60 * 60 * 1000)) ~/ (60 * 1000);
    
    if (days > 0) return '$days days ago';
    if (hours > 0) return '$hours hours ago';
    if (minutes > 0) return '$minutes minutes ago';
    return 'Just now';
  }

  // Logout and clear all data
  static Future<void> logout({bool keepRememberedCredentials = false}) async {
    await FirebaseAuth.instance.signOut();
    await clearSession();
    
    if (!keepRememberedCredentials) {
      await clearRememberedCredentials();
    }
  }
}
