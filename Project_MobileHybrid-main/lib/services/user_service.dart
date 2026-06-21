import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service.dart';
class UserService {
  Map<String, String> get _headers {
    final token = AuthService().token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/profile'),
        headers: _headers,
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
        Uri.parse('${ApiConfig.baseUrl}/users/profile/me'),
        headers: _headers,
        body: jsonEncode({'name': name, 'bio': bio, 'avatar': avatar}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update user profile error: $e');
      return false;
    }
  }
  Future<bool> followUser(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/follow'),
        headers: _headers,
        body: jsonEncode({}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Follow user error: $e');
      return false;
    }
  }
  Future<bool> unfollowUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/follow'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Unfollow user error: $e');
      return false;
    }
  }
  Future<Map<String, dynamic>?> getFollowers(String userId, {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/followers?page=$page&limit=$limit'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get followers error: $e');
      return null;
    }
  }
  Future<Map<String, dynamic>?> getFollowing(String userId, {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/following?page=$page&limit=$limit'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get following error: $e');
      return null;
    }
  }
  Future<bool> updateSettings({
    required String userId,
    bool? darkMode,
    bool? notificationsEnabled,
    String? calorieUnit,
    String? distanceUnit,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (darkMode != null) body['darkMode'] = darkMode;
      if (notificationsEnabled != null) body['notificationsEnabled'] = notificationsEnabled;
      if (calorieUnit != null) body['calorieUnit'] = calorieUnit;
      if (distanceUnit != null) body['distanceUnit'] = distanceUnit;
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/profile/me/settings'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Update settings error: $e');
      return false;
    }
  }
}
