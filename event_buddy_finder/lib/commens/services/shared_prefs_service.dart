import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // Singleton instance
  static SharedPrefsService? _instance;
  static SharedPreferences? _prefs;

  // Private constructor
  SharedPrefsService._();

  // Factory method to initialize and get the instance
  static Future<SharedPrefsService> getInstance() async {
    if (_instance == null) {
      _instance = SharedPrefsService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // -----------------------
  // Generic helper methods
  // -----------------------

  Future<bool> setBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs!.getBool(key) ?? defaultValue;
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs!.getInt(key) ?? defaultValue;
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs!.getDouble(key) ?? defaultValue;
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    return _prefs!.getString(key) ?? defaultValue;
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs!.setStringList(key, value);
  }

  List<String> getStringList(String key, {List<String> defaultValue = const []}) {
    return _prefs!.getStringList(key) ?? defaultValue;
  }

  // Remove a key
  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  // Clear all prefs (use with caution!)
  Future<bool> clear() async {
    return await _prefs!.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }

  // Example for a specific key — you can add more of these for your app

  static const _keyIsLoggedIn = 'is_logged_in';

  Future<bool> setIsLoggedIn(bool value) async {
    return await setBool(_keyIsLoggedIn, value);
  }

  bool getIsLoggedIn() {
    return getBool(_keyIsLoggedIn, defaultValue: false);
  }
}
