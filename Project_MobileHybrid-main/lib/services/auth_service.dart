import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
class AuthService {
  static final AuthService _instance = AuthService._internal();
  String? _token;
  String? _userId;
  AuthService._internal();
  factory AuthService() {
    return _instance;
  }
  String? get token => _token;
  String? get userId => _userId;
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          _token = data['token'] as String?;
          _userId = data['user']?['id'] as String?;
          return data;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }
  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name ?? 'New User',
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          _token = data['token'] as String?;
          _userId = data['user']?['id'] as String?;
          return data;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Register error: $e');
      return null;
    }
  }
  void logout() {
    _token = null;
    _userId = null;
  }
}
