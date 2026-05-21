import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/food_result.dart';
import '../config/api_config.dart';

class CalorieService {

  Future<List<FoodResult>> searchFoods(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/calories/search-foods?query=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Search foods response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          final foods = (data['data'] as List<dynamic>)
              .map((f) => FoodResult.fromJson(f))
              .toList();
          return foods;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Search foods error: $e');
      return [];
    }
  }

  Future<bool> logMeal({
    required String userId,
    required String mealType,
    required String foodQuery,
    required int servingSize,
    String? fdsId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/calories/log-meal'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mealType': mealType,
          'foodQuery': foodQuery,
          'servingSize': servingSize,
          'fdsId': fdsId,
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
        Uri.parse('${ApiConfig.baseUrl}/calories/target'),
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
        Uri.parse('${ApiConfig.baseUrl}/calories/daily-stats/$userId'),
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
        Uri.parse('${ApiConfig.baseUrl}/calories/history/$userId'),
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
        Uri.parse('${ApiConfig.baseUrl}/calories/stats/$userId'),
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

