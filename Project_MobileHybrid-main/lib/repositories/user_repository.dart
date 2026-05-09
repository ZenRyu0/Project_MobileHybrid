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
}
