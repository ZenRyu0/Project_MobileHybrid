import '../services/workout_service.dart';

class WorkoutRepository {
  final WorkoutService _workoutService;

  WorkoutRepository(this._workoutService);

  Future<List<dynamic>> getWorkoutPlans() {
    return _workoutService.getWorkoutPlans();
  }

  Future<Map<String, dynamic>?> getWorkoutPlanById(String id) {
    return _workoutService.getWorkoutPlanById(id);
  }

  Future<bool> logWorkout({
    required String userId,
    required String name,
    required int duration,
    required int caloriesBurned,
    required String difficulty,
    required List<String> exercises,
  }) {
    return _workoutService.logWorkout(
      userId: userId,
      name: name,
      duration: duration,
      caloriesBurned: caloriesBurned,
      difficulty: difficulty,
      exercises: exercises,
    );
  }

  Future<bool> createWorkoutPlan({
    required String name,
    required int duration,
    required String difficulty,
    required String userId,
    required List<dynamic> exercises,
  }) {
    return _workoutService.createWorkoutPlan(
      name: name,
      duration: duration,
      difficulty: difficulty,
      userId: userId,
      exercises: exercises,
    );
  }

  Future<List<dynamic>> getWorkoutHistory(String userId) {
    return _workoutService.getWorkoutHistory(userId);
  }

  Future<Map<String, dynamic>?> getWorkoutStats(String userId) {
    return _workoutService.getWorkoutStats(userId);
  }
}
