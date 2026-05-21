import '../models/food_result.dart';
import '../services/calorie_service.dart';

class CalorieRepository {
  final CalorieService _calorieService;

  CalorieRepository(this._calorieService);

  Future<List<FoodResult>> searchFoods(String query, {bool isBranded = false}) {
    return _calorieService.searchFoods(query, isBranded: isBranded);
  }

  Future<bool> logMeal({
    required String userId,
    required String mealType,
    required String foodQuery,
    required int servingSize,
    String? fdsId,
  }) {
    return _calorieService.logMeal(
      userId: userId,
      mealType: mealType,
      foodQuery: foodQuery,
      servingSize: servingSize,
      fdsId: fdsId,
    );
  }

  Future<bool> setDailyTarget({
    required String userId,
    required int dailyTarget,
  }) {
    return _calorieService.setDailyTarget(
      userId: userId,
      dailyTarget: dailyTarget,
    );
  }

  Future<Map<String, dynamic>?> getDailyStats(String userId) {
    return _calorieService.getDailyStats(userId);
  }

  Future<List<dynamic>> getCalorieHistory(String userId) {
    return _calorieService.getCalorieHistory(userId);
  }

  Future<Map<String, dynamic>?> getTotalStats(String userId) {
    return _calorieService.getTotalStats(userId);
  }
}
