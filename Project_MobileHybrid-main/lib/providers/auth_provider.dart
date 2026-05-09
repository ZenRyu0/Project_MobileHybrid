import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String _errorMessage = '';
  String _userEmail = '';

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String get errorMessage => _errorMessage;
  String get userEmail => _userEmail;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError('');

    final success = await _authRepository.login(email: email, password: password);
    _setLoading(false);

    if (success) {
      _setAuthenticated(true);
      _userEmail = email;
      return true;
    }

    _setError('Invalid email or password.');
    return false;
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _setError('');

    final success = await _authRepository.register(email: email, password: password);
    _setLoading(false);

    if (success) {
      _setAuthenticated(true);
      _userEmail = email;
      return true;
    }

    _setError('Registration failed. Please try again.');
    return false;
  }

  void logout() {
    _setAuthenticated(false);
    _userEmail = '';
    _setError('');
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
