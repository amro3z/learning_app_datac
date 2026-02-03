import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:training/data/api/api_constant.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SharedPreferences? _prefs;
  bool _isRefreshing = false;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String? get token => _prefs?.getString('auth_token');
  String? get refreshToken => _prefs?.getString('refresh_token');
  bool get hasToken => token != null;

Future<void> saveTokens(String token, String refreshToken) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    await _prefs!.setString('auth_token', token);
    await _prefs!.setString('refresh_token', refreshToken);
  }


  Future<bool> refreshTokenIfNeeded() async {
    if (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 300));
      return token != null;
    }

    if (refreshToken == null) return false;

    _isRefreshing = true;

    final res = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh_token": refreshToken, "mode": "json"}),
    );

    _isRefreshing = false;

    if (res.statusCode != 200) return false;

    final body = jsonDecode(res.body);
    await saveTokens(
      body['data']['access_token'],
      body['data']['refresh_token'] ?? refreshToken!,
    );

    return true;
  }

  Future<void> logout() async {
    await _prefs?.clear();
  }
}
