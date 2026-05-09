import '../services/calorie_service.dart';

class CalorieRepository {
  final CalorieService _calorieService;

  CalorieRepository(this._calorieService);

  Future<bool> logMeal({
    required String userId,
    required String mealType,
    required String foodName,
    required int calories,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return _calorieService.logMeal(
      userId: userId,
      mealType: mealType,
      foodName: foodName,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
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