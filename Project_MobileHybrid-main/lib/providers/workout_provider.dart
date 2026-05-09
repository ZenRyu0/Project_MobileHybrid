import 'package:flutter/material.dart';
import '../repositories/workout_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  WorkoutProvider(this._workoutRepository);

  List<dynamic> _workoutPlans = [];
  Map<String, dynamic>? _workoutStats;
  bool _isLoading = false;
  String _errorMessage = '';

  List<dynamic> get workoutPlans => _workoutPlans;
  Map<String, dynamic>? get workoutStats => _workoutStats;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchWorkoutPlans() async {
    _setLoading(true);
    _setError('');

    try {
      final plans = await _workoutRepository.getWorkoutPlans();
      _workoutPlans = plans;
    } catch (e) {
      _setError('Error fetching workouts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchWorkoutStats(String userId) async {
    _setLoading(true);
    _setError('');

    try {
      final stats = await _workoutRepository.getWorkoutStats(userId);
      _workoutStats = stats;
    } catch (e) {
      _setError('Error fetching stats: $e');
    } finally {
      _setLoading(false);
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
    _setLoading(true);
    _setError('');

    try {
      final success = await _workoutRepository.logWorkout(
        userId: userId,
        name: name,
        duration: duration,
        caloriesBurned: caloriesBurned,
        difficulty: difficulty,
        exercises: exercises,
      );

      if (success) {
        await fetchWorkoutStats(userId);
      } else {
        _setError('Failed to log workout');
      }
      return success;
    } catch (e) {
      _setError('Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCustomPlan({
    required String name,
    required int duration,
    required String difficulty,
    required String userId,
    required List<dynamic> exercises,
  }) async {
    _setLoading(true);
    _setError('');

    try {
      final success = await _workoutRepository.createWorkoutPlan(
        name: name,
        duration: duration,
        difficulty: difficulty,
        userId: userId,
        exercises: exercises,
      );

      if (success) {
        await fetchWorkoutPlans();
      } else {
        _setError('Failed to create custom routine');
      }
      return success;
    } catch (e) {
      _setError('Error: $e');
      return false;
    } finally {
      _setLoading(false);
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
