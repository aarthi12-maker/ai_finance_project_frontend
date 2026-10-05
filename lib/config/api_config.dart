/// API configuration for Finance AI backend.
abstract final class ApiConfig {
  static const baseUrl = 'http://localhost:9000/api';

  static const register = '$baseUrl/auth/register';
  static const login = '$baseUrl/auth/login';
  static const me = '$baseUrl/auth/me';

  static const categories = '$baseUrl/categories';

  static String categoryById(int id) => '$categories/$id';
  static String categoryUpdate(int id) => '$categories/$id/update';
  static String categoryDelete(int id) => '$categories/$id/delete';
}
