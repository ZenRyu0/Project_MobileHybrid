import 'package:http/http.dart' as http;
import 'dart:convert';

class WorkoutService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<List<dynamic>> getWorkoutPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workouts/plans'),
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
      print('Get workouts error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getWorkoutPlanById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workouts/plans/$id'),
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
      print('Get workout error: $e');
      return null;
    }
  }

  Future<bool> logWorkout({
    required String userId,
    required String name,
    required int duration,
    required int caloriesBurned,
    required String difficulty,
    required List<String> exercises,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/workouts/log'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'name': name,
          'duration': duration,
          'caloriesBurned': caloriesBurned,
          'difficulty': difficulty,
          'exercises': exercises,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Log workout error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getWorkoutHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workouts/history/$userId'),
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
      print('Get workout history error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getWorkoutStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workouts/stats/$userId'),
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
      print('Get workout stats error: $e');
      return null;
    }
  }

  Future<bool> createWorkoutPlan({
    required String name,
    required int duration,
    required String difficulty,
    required String userId,
    required List<dynamic> exercises,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/workouts/plans'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'duration': duration,
          'difficulty': difficulty,
          'userId': userId,
          'isCustom': true,
          'exercises': exercises,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Create workout plan error: $e');
      return false;
    }
  }
}
