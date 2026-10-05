import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:finance_frontend/config/api_config.dart';
import 'package:finance_frontend/models/user_profile.dart';
import 'package:finance_frontend/services/auth_service.dart';

/// Fetches the authenticated user profile from `/api/auth/me`.
class AuthProfileService {
  AuthProfileService({
    http.Client? client,
    AuthService? authService,
  })  : _client = client ?? http.Client(),
        _authService = authService ?? AuthService();

  final http.Client _client;
  final AuthService _authService;

  /// GET http://localhost:9000/api/auth/me
  /// Requires Bearer token saved after login/register.
  Future<ProfileResponse> getProfile() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      return const ProfileResponse(
        status: false,
        message: 'Session expired. Please sign in again.',
      );
    }

    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.me),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        return const ProfileResponse(
          status: false,
          message: 'Unauthorized. Please sign in again.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const ProfileResponse(
          status: false,
          message: 'Unexpected server response',
        );
      }

      return ProfileResponse.fromJson(decoded);
    } on FormatException {
      return const ProfileResponse(
        status: false,
        message: 'Invalid response from server',
      );
    } catch (_) {
      return const ProfileResponse(
        status: false,
        message: 'Unable to reach server. Check your connection.',
      );
    }
  }
}
