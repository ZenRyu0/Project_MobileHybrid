import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
class SettingsProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  SettingsProvider(this._userRepository);
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _calorieUnit = 'kcal';
  String _distanceUnit = 'km';
  bool _isLoading = false;
  String _errorMessage = '';
  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get calorieUnit => _calorieUnit;
  String get distanceUnit => _distanceUnit;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }
  void setNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }
  void setCalorieUnit(String unit) {
    _calorieUnit = unit;
    notifyListeners();
  }
  void setDistanceUnit(String unit) {
    _distanceUnit = unit;
    notifyListeners();
  }
  Future<bool> saveSettings(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _userRepository.updateSettings(
        userId: userId,
        darkMode: _darkMode,
        notificationsEnabled: _notificationsEnabled,
        calorieUnit: _calorieUnit,
        distanceUnit: _distanceUnit,
      );
      if (!success) {
        _errorMessage = 'Failed to save settings';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void loadSettings(Map<String, dynamic> profile) {
    _darkMode = profile['darkMode'] as bool? ?? false;
    _notificationsEnabled = profile['notificationsEnabled'] as bool? ?? true;
    _calorieUnit = profile['calorieUnit'] as String? ?? 'kcal';
    _distanceUnit = profile['distanceUnit'] as String? ?? 'km';
    notifyListeners();
  }
}
