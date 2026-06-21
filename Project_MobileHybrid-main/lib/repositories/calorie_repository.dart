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
    String? token,
    String? fdsId,
  }) {
    return _calorieService.logMeal(
      userId: userId,
      mealType: mealType,
      foodQuery: foodQuery,
      servingSize: servingSize,
      token: token ?? '',
      fdsId: fdsId,
    );
  }
  Future<bool> deleteMeal(String mealId, String userId, String token) {
    return _calorieService.deleteMeal(mealId, userId, token);
  }
  Future<bool> setDailyTarget({
    required String userId,
    required int dailyTarget,
    required String token,
  }) {
    return _calorieService.setDailyTarget(
      userId: userId,
      dailyTarget: dailyTarget,
      token: token,
    );
  }
  Future<Map<String, dynamic>?> getDailyStats(String userId, String token) {
    return _calorieService.getDailyStats(userId, token);
  }
  Future<List<dynamic>> getCalorieHistory(String userId, String token) {
    return _calorieService.getCalorieHistory(userId, token);
  }
  Future<Map<String, dynamic>?> getTotalStats(String userId, String token) {
    return _calorieService.getTotalStats(userId, token);
  }
}
