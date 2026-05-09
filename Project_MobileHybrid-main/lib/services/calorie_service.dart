import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalorieService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<bool> logMeal({
    required String userId,
    required String mealType,
    required String foodName,
    required int calories,
    int? protein,
    int? carbs,
    int? fat,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calories/log-meal'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'mealType': mealType,
          'foodName': foodName,
          'calories': calories,
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
        }),
      );

      debugPrint('Log meal response: ${response.statusCode}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Log meal error: $e');
      return false;
    }
  }

  Future<bool> setDailyTarget({
    required String userId,
    required int dailyTarget,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/calories/target'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'dailyTarget': dailyTarget}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Set daily target error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getDailyStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/calories/daily-stats/$userId'),
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
      debugPrint('Get daily stats error: $e');
      return null;
    }
  }

  Future<List<dynamic>> getCalorieHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/calories/history/$userId'),
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
      debugPrint('Get calorie history error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getTotalStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/calories/stats/$userId'),
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
      debugPrint('Get total stats error: $e');
      return null;
    }
  }
}
