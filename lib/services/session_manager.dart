// File: lib/services/session_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Key for SharedPreferences
  static const String _keyIsLoggedIn = 'isLoggedIn';
 
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }
 
  // Login - save session data
  static Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
  }
 
  // Logout - clear session data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // Check session status and redirect accordingly
  static Future<bool> checkAndRedirect() async {
    // Get login status
    bool loggedIn = await isLoggedIn();
    return loggedIn;
  }
}