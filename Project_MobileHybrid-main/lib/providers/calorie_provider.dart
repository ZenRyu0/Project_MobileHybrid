import 'package:flutter/material.dart';
import '../models/food_result.dart';
import '../repositories/calorie_repository.dart';

class CalorieProvider extends ChangeNotifier {
  final CalorieRepository _calorieRepository;

  CalorieProvider(this._calorieRepository);

  Map<String, dynamic>? _dailyStats;
  List<FoodResult> _foodSearchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _errorMessage = '';

  Map<String, dynamic>? get dailyStats => _dailyStats;
  List<FoodResult> get foodSearchResults => _foodSearchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
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

  Future<void> searchFoods(String query) async {
    if (query.isEmpty) {
      _foodSearchResults = [];
      notifyListeners();
      return;
    }

    _setSearching(true);
    _setError('');

    try {
      final results = await _calorieRepository.searchFoods(query);
      _foodSearchResults = results;
    } catch (e) {
      _setError('Error searching foods: $e');
      _foodSearchResults = [];
    } finally {
      _setSearching(false);
    }
  }

  Future<bool> logMeal({
    required String userId,
    required String mealType,
    required String foodQuery,
    required int servingSize,
    String? fdsId,
  }) async {
    _setLoading(true);
    _setError('');

    try {
      final success = await _calorieRepository.logMeal(
        userId: userId,
        mealType: mealType,
        foodQuery: foodQuery,
        servingSize: servingSize,
        fdsId: fdsId,
      );

      if (success) {
        await fetchDailyStats(userId);
        _foodSearchResults = [];
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

  void _setSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
