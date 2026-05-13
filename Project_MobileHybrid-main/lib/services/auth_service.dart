import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'https://go-fit-production-1a8c.up.railway.app';
  String? _token;
  String? _userId;

  String? get token => _token;
  String? get userId => _userId;

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _token = data['token'];
          _userId = data['user']['id'];
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
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name ?? 'New User',
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _token = data['token'];
          _userId = data['user']['id'];
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
