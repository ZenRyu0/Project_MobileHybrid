import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  UserProvider(this._userRepository);

  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String _errorMessage = '';

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchUserProfile(String userId) async {
    _setLoading(true);
    _setError('');

    try {
      final profile = await _userRepository.getUserProfile(userId);
      _userProfile = profile;
      if (profile == null) {
        _setError('Failed to load user profile');
      }
    } catch (e) {
      _setError('Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatar,
  }) async {
    _setLoading(true);
    _setError('');

    try {
      final success = await _userRepository.updateUserProfile(
        userId: userId,
        name: name,
        bio: bio,
        avatar: avatar,
      );

      if (success) {
        await fetchUserProfile(userId);
      } else {
        _setError('Failed to update profile');
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