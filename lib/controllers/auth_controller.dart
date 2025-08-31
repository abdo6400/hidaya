import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/services/auth_service.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AppUser?>(
  (ref) => AuthController(AuthService()),
);

class AuthController extends StateNotifier<AppUser?> {
  static const String _userKey = 'user_data';
  final AuthService _authService;
  late final SharedPreferences _prefs;

  AuthController(this._authService) : super(null) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUser();
  }

  Future<void> _saveUser(AppUser user) async {
    final userMap = user.toJsonMap();
    await _prefs.setString(_userKey, jsonEncode(userMap));
  }

  Future<void> _loadUser() async {
    final userData = _prefs.getString(_userKey);
    if (userData != null) {
      try {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        state = AppUser(
          id: userMap['id'] as String,
          name: userMap['name'] as String,
          username: userMap['username'] as String,
          role: _roleFromString(userMap['role'] as String),
          email: userMap['email'] as String?,
          phone: userMap['phone'] as String?,
          status: userMap['status'] as String? ?? 'active',
          createdAt: userMap['createdAt'] != null
              ? DateTime.parse(userMap['createdAt'] as String)
              : null,
          lastLogin: userMap['lastLogin'] != null
              ? DateTime.parse(userMap['lastLogin'] as String)
              : null,
        );
      } catch (e) {
        await _clearUser();
      }
    }
  }

  UserRole _roleFromString(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'sheikh':
        return UserRole.sheikh;
      case 'parent':
      default:
        return UserRole.parent;
    }
  }

  Future<void> _clearUser() async {
    await _prefs.remove(_userKey);
  }

  Future<AppUser?> registerAsParent({
    required String username,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final user = await _authService.register(
        username: username,
        password: password,
        name: name,
        role: UserRole.parent,
        phone: phone,
      );

      if (user.status == 'active') {
        state = user;
        await _saveUser(user);
      } else {
        state = null;
        await _clearUser();
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
        await _saveUser(user);
      } else {
        state = null;
        await _clearUser();
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await _clearUser();
    state = null;
  }
}
