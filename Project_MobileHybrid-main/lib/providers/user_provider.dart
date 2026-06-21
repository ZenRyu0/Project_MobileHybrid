import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  UserProvider(this._userRepository);
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _searchResults = [];
  bool _isFollowing = false;
  List<dynamic> _followers = [];
  List<dynamic> _following = [];
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get searchResults => _searchResults;
  bool get isFollowing => _isFollowing;
  List<dynamic> get followers => _followers;
  List<dynamic> get following => _following;
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
  Future<List<dynamic>> searchUsers(String query) async {
    try {
      final results = await _userRepository.getAllUsers();
      _searchResults = results
          .where((user) {
            final name = user['name'] as String? ?? '';
            final email = user['email'] as String? ?? '';
            final lowerQuery = query.toLowerCase();
            return name.toLowerCase().contains(lowerQuery) ||
                email.toLowerCase().contains(lowerQuery);
          })
          .toList();
      notifyListeners();
      return _searchResults;
    } catch (e) {
      _setError('Error searching users: $e');
      return [];
    }
  }
  Future<bool> followUser(String userId) async {
    try {
      final success = await _userRepository.followUser(userId);
      if (success) {
        _isFollowing = true;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Error following user: $e');
      return false;
    }
  }
  Future<bool> unfollowUser(String userId) async {
    try {
      final success = await _userRepository.unfollowUser(userId);
      if (success) {
        _isFollowing = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Error unfollowing user: $e');
      return false;
    }
  }
  Future<void> getFollowers(String userId) async {
    try {
      final result = await _userRepository.getFollowers(userId);
      if (result != null) {
        _followers = result['followers'] as List<dynamic>? ?? [];
        notifyListeners();
      }
    } catch (e) {
      _setError('Error fetching followers: $e');
    }
  }
  Future<void> getFollowing(String userId) async {
    try {
      final result = await _userRepository.getFollowing(userId);
      if (result != null) {
        _following = result['following'] as List<dynamic>? ?? [];
        notifyListeners();
      }
    } catch (e) {
      _setError('Error fetching following: $e');
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