import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class UserService {

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/profile'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get user profile error: $e');
      return null;
    }
  }

  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Get all users error: $e');
      return [];
    }
  }

  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatar,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'bio': bio, 'avatar': avatar}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update user profile error: $e');
      return false;
    }
  }
}
