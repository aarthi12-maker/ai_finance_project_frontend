import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:finance_frontend/config/api_config.dart';
import 'package:finance_frontend/models/category_models.dart';
import 'package:finance_frontend/services/auth_service.dart';

class CategoryService {
  CategoryService({
    http.Client? client,
    AuthService? authService,
  })  : _client = client ?? http.Client(),
        _authService = authService ?? AuthService();

  final http.Client _client;
  final AuthService _authService;

  Future<CategoryListResponse> getCategories() async {
    final result = await _send(
      method: 'GET',
      url: ApiConfig.categories,
    );
    if (!result.ok) {
      return CategoryListResponse(status: false, message: result.message);
    }
    return CategoryListResponse.fromJson(result.body!);
  }

  Future<CategoryDetailResponse> getCategory(int categoryId) async {
    final result = await _send(
      method: 'GET',
      url: ApiConfig.categoryById(categoryId),
    );
    if (!result.ok) {
      return CategoryDetailResponse(status: false, message: result.message);
    }
    return CategoryDetailResponse.fromJson(result.body!);
  }

  Future<CategoryMutationResponse> createCategory(CategoryRequest request) async {
    final result = await _send(
      method: 'POST',
      url: ApiConfig.categories,
      body: request.toJson(),
    );
    if (!result.ok) {
      return CategoryMutationResponse(status: false, message: result.message);
    }
    return CategoryMutationResponse.fromJson(result.body!);
  }

  Future<CategoryMutationResponse> updateCategory({
    required int categoryId,
    required CategoryRequest request,
  }) async {
    final result = await _send(
      method: 'POST',
      url: ApiConfig.categoryUpdate(categoryId),
      body: request.toJson(),
    );
    if (!result.ok) {
      return CategoryMutationResponse(status: false, message: result.message);
    }
    return CategoryMutationResponse.fromJson(result.body!);
  }

  Future<CategoryMutationResponse> deleteCategory(int categoryId) async {
    final result = await _send(
      method: 'POST',
      url: ApiConfig.categoryDelete(categoryId),
    );
    if (!result.ok) {
      return CategoryMutationResponse(status: false, message: result.message);
    }
    return CategoryMutationResponse.fromJson(result.body!);
  }

  Future<_ApiResult> _send({
    required String method,
    required String url,
    Map<String, dynamic>? body,
  }) async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      return const _ApiResult(
        ok: false,
        message: 'Session expired. Please sign in again.',
      );
    }

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      late final http.Response response;
      final uri = Uri.parse(url);

      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers);
        case 'POST':
          response = await _client.post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
        default:
          return const _ApiResult(ok: false, message: 'Unsupported method');
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return const _ApiResult(
          ok: false,
          message: 'Unauthorized. Please sign in again.',
        );
      }

      if (response.body.isEmpty) {
        return _ApiResult(
          ok: response.statusCode >= 200 && response.statusCode < 300,
          message: response.statusCode >= 200 && response.statusCode < 300
              ? 'Success'
              : 'Request failed (${response.statusCode})',
          body: const {'status': true, 'message': 'Success'},
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const _ApiResult(
          ok: false,
          message: 'Unexpected server response',
        );
      }

      final success = decoded['status'] == true ||
          (response.statusCode >= 200 && response.statusCode < 300);
      return _ApiResult(
        ok: success,
        message: decoded['message'] as String? ??
            (success ? 'Success' : 'Request failed'),
        body: decoded,
      );
    } on FormatException {
      return const _ApiResult(
        ok: false,
        message: 'Invalid response from server',
      );
    } catch (_) {
      return const _ApiResult(
        ok: false,
        message: 'Unable to reach server. Check your connection.',
      );
    }
  }
}

class _ApiResult {
  const _ApiResult({
    required this.ok,
    required this.message,
    this.body,
  });

  final bool ok;
  final String message;
  final Map<String, dynamic>? body;
}
