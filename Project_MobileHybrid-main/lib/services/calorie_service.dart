import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/food_result.dart';
class CalorieService {
  Future<List<FoodResult>> searchFoods(
    String query, {
    bool isBranded = false,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/calories/search-foods?query=$query&branded=$isBranded',
        ),
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint('Search foods response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          final foods =
              (data['data'] as List<dynamic>)
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
    required String token,
    String? fdsId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/calories/log-meal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
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
  Future<bool> deleteMeal(String mealId, String userId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/calories/meals/$mealId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('Delete meal response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Delete meal error: $e');
      return false;
    }
  }
  Future<bool> setDailyTarget({
    required String userId,
    required int dailyTarget,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/calories/target'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId, 'dailyTarget': dailyTarget}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Set daily target error: $e');
      return false;
    }
  }
  Future<Map<String, dynamic>?> getDailyStats(
    String userId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/calories/daily-stats/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get daily stats error: $e');
      return null;
    }
  }
  Future<List<dynamic>> getCalorieHistory(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/calories/history/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
  Future<Map<String, dynamic>?> getTotalStats(
    String userId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/calories/stats/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
