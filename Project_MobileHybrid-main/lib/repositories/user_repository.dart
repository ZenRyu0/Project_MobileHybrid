import '../services/user_service.dart';
class UserRepository {
  final UserService _userService;
  UserRepository(this._userService);
  Future<Map<String, dynamic>?> getUserProfile(String userId) {
    return _userService.getUserProfile(userId);
  }
  Future<List<dynamic>> getAllUsers() {
    return _userService.getAllUsers();
  }
  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatar,
  }) {
    return _userService.updateUserProfile(
      userId: userId,
      name: name,
      bio: bio,
      avatar: avatar,
    );
  }
  Future<bool> followUser(String userId) {
    return _userService.followUser(userId);
  }
  Future<bool> unfollowUser(String userId) {
    return _userService.unfollowUser(userId);
  }
  Future<Map<String, dynamic>?> getFollowers(String userId, {int page = 1, int limit = 10}) {
    return _userService.getFollowers(userId, page: page, limit: limit);
  }
  Future<Map<String, dynamic>?> getFollowing(String userId, {int page = 1, int limit = 10}) {
    return _userService.getFollowing(userId, page: page, limit: limit);
  }
  Future<bool> updateSettings({
    required String userId,
    bool? darkMode,
    bool? notificationsEnabled,
    String? calorieUnit,
    String? distanceUnit,
  }) {
    return _userService.updateSettings(
      userId: userId,
      darkMode: darkMode,
      notificationsEnabled: notificationsEnabled,
      calorieUnit: calorieUnit,
      distanceUnit: distanceUnit,
    );
  }
}
