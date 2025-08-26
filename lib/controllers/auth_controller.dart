import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/services/auth_service.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AppUser?>(
  (ref) => AuthController(AuthService()),
);

class AuthController extends StateNotifier<AppUser?> {
  final AuthService _authService;
  AuthController(this._authService) : super(null);

  Future<AppUser?> registerAsParent({
    required String username,
    required String password,
    required String phone,
  }) async {
    try {
      final user = await _authService.register(
        username: username,
        password: password,
        role: UserRole.parent,
        phone: phone,
      );

      if (user.status == 'active') {
        state = user;
      } else {
        state = null;
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<AppUser?> login({required String username, required String password}) async {
    try {
      final user = await _authService.login(username: username, password: password);

      if (user.status == 'active') {
        state = user;
      } else {
        state = null;
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }
}
