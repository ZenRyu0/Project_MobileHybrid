import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<bool> login({required String email, required String password}) async {
    final result = await _authService.login(email: email, password: password);
    return result != null;
  }

  Future<bool> register({required String email, required String password}) async {
    final result = await _authService.register(email: email, password: password);
    return result != null;
  }

  String? getToken() => _authService.token;
  String? getUserId() => _authService.userId;

  void logout() => _authService.logout();
}
