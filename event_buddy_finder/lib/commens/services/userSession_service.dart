import 'dart:convert';
import 'package:event_buddy_finder/futures/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const _userKey = 'user_data';
  static const _tokenKey = 'auth_token';

  UserModel? _user;
  String? _token;

  UserModel? get user => _user;
  String? get token => _token;

  bool get isLoggedIn => _user != null && _token != null;

  /// Load user data and token from secure storage
  Future<void> loadUserFromStorage() async {
    final userJson = await _secureStorage.read(key: _userKey);
    final token = await _secureStorage.read(key: _tokenKey);

    if (userJson != null) {
      final userMap = jsonDecode(userJson);
      _user = UserModel.fromJson(userMap);
    }

    _token = token;
  }

  /// Save user data and token to secure storage
  Future<void> saveUserToStorage(UserModel user, String token) async {
    _user = user;
    _token = token;
    final userJson = jsonEncode(user.toJson());

    await _secureStorage.write(key: _userKey, value: userJson);
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Clear user data and token from secure storage
  Future<void> clearUser() async {
    _user = null;
    _token = null;

    await _secureStorage.delete(key: _userKey);
    await _secureStorage.delete(key: _tokenKey);
  }
}
