import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finance_frontend/config/api_config.dart';
import 'package:finance_frontend/models/auth_models.dart';

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _postAuth(
      ApiConfig.register,
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      },
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return _postAuth(
      ApiConfig.login,
      body: {
        'email': email.trim(),
        'password': password,
      },
    );
  }

  Future<AuthResponse> _postAuth(
    String url, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const AuthResponse(
          status: false,
          message: 'Unexpected server response',
        );
      }

      final auth = AuthResponse.fromJson(decoded);
      if (auth.status && auth.data != null) {
        await saveSession(auth.data!);
      }
      return auth;
    } on FormatException {
      return const AuthResponse(
        status: false,
        message: 'Invalid response from server',
      );
    } catch (_) {
      return const AuthResponse(
        status: false,
        message: 'Unable to reach server. Check your connection.',
      );
    }
  }

  Future<void> saveSession(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, user.token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<AuthUser?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
