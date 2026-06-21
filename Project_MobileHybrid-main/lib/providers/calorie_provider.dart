import 'package:flutter/material.dart';
import '../models/food_result.dart';
import '../repositories/calorie_repository.dart';
import '../repositories/auth_repository.dart';
class CalorieProvider extends ChangeNotifier {
  final CalorieRepository _calorieRepository;
  final AuthRepository _authRepository;
  CalorieProvider(this._calorieRepository, this._authRepository);
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
      final token = _authRepository.getToken();
      if (token == null) {
        _setError('Not authenticated');
        return;
      }
      final stats = await _calorieRepository.getDailyStats(userId, token);
      _dailyStats = stats;
    } catch (e) {
      _setError('Error fetching calorie stats: $e');
    } finally {
      _setLoading(false);
    }
  }
  Future<void> getDailyStats(String userId, String token) async {
    return fetchDailyStats(userId);
  }
  Future<void> searchFoods(String query, {bool isBranded = false}) async {
    if (query.isEmpty) {
      _foodSearchResults = [];
      notifyListeners();
      return;
    }
    _setSearching(true);
    _setError('');
    try {
      final results = await _calorieRepository.searchFoods(
        query,
        isBranded: isBranded,
      );
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
    required String fdsId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = _authRepository.getToken();
      if (token == null) {
        _errorMessage = 'Not authenticated';
        return false;
      }
      final success = await _calorieRepository.logMeal(
        userId: userId,
        mealType: mealType,
        foodQuery: foodQuery,
        servingSize: servingSize,
        fdsId: fdsId,
        token: token,
      );
      if (success) {
        await fetchDailyStats(userId);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> deleteMeal({
    required String mealId,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = _authRepository.getToken();
      if (token == null) {
        _errorMessage = 'Not authenticated';
        return false;
      }
      final success = await _calorieRepository.deleteMeal(
        mealId,
        userId,
        token,
      );
      if (success) {
        await fetchDailyStats(userId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete meal: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> setDailyTarget({
    required String userId,
    required int dailyTarget,
  }) async {
    try {
      final token = _authRepository.getToken();
      if (token == null) {
        _setError('Not authenticated');
        return false;
      }
      return await _calorieRepository.setDailyTarget(
        userId: userId,
        dailyTarget: dailyTarget,
        token: token,
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
