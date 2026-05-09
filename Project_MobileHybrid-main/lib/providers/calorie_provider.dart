import 'package:flutter/material.dart';
import '../repositories/calorie_repository.dart';

class CalorieProvider extends ChangeNotifier {
  final CalorieRepository _calorieRepository;

  CalorieProvider(this._calorieRepository);

  Map<String, dynamic>? _dailyStats;
  bool _isLoading = false;
  String _errorMessage = '';

  Map<String, dynamic>? get dailyStats => _dailyStats;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchDailyStats(String userId) async {
    _setLoading(true);
    _setError('');

    try {
      final stats = await _calorieRepository.getDailyStats(userId);
      _dailyStats = stats;
    } catch (e) {
      _setError('Error fetching calorie stats: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> logMeal({
    required String userId,
    required String mealType,
    required String foodName,
    required int calories,
    int? protein,
    int? carbs,
    int? fat,
  }) async {
    _setLoading(true);
    _setError('');

    try {
      final success = await _calorieRepository.logMeal(
        userId: userId,
        mealType: mealType,
        foodName: foodName,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );

      if (success) {
        await fetchDailyStats(userId);
      } else {
        _setError('Failed to log meal');
      }
      return success;
    } catch (e) {
      _setError('Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> setDailyTarget({
    required String userId,
    required int dailyTarget,
  }) async {
    try {
      return await _calorieRepository.setDailyTarget(
        userId: userId,
        dailyTarget: dailyTarget,
      );
    } catch (e) {
      _setError('Error: $e');
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}