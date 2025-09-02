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
  bool _initialized = false;

  AuthController(this._authService) : super(null) {
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadUser();
      _initialized = true;
    } catch (e) {
      print('AuthController initialization error: $e');
      _initialized = true;
    }
  }

  Future<void> _saveUser(AppUser user) async {
    try {
      final userMap = user.toJsonMap();
      print(userMap);
      await _prefs.setString(_userKey, jsonEncode(userMap));
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  Future<void> _loadUser() async {
    try {
      final userData = _prefs.getString(_userKey);
      if (userData != null && userData.isNotEmpty) {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        print(userMap);
        // Safely extract values with null checks
        final id = userMap['id'] as String?;
        final name = userMap['name'] as String?;
        final username = userMap['username'] as String?;
        final roleString = userMap['role'] as String?;
        final email = userMap['email'] as String?;
        final phone = userMap['phone'] as String?;
        final status = userMap['status'] as String? ?? 'active';
        final createdAtString = userMap['createdAt'] as String?;
        final lastLoginString = userMap['lastLogin'] as String?;
        
        // Validate required fields
        if (id == null || name == null || username == null || roleString == null) {
          print('Missing required user fields, clearing invalid data');
          await _clearUser();
          return;
        }
        
        // Validate that required fields are not empty
        if (id.isEmpty || name.isEmpty || username.isEmpty || roleString.isEmpty) {
          print('Required user fields are empty, clearing invalid data');
          await _clearUser();
          return;
        }
        
        // Parse dates safely
        DateTime? createdAt;
        DateTime? lastLogin;
        
        if (createdAtString != null && createdAtString.isNotEmpty) {
          try {
            createdAt = DateTime.parse(createdAtString);
          } catch (e) {
            print('Error parsing createdAt: $e');
          }
        }
        
        if (lastLoginString != null && lastLoginString.isNotEmpty) {
          try {
            lastLogin = DateTime.parse(lastLoginString);
          } catch (e) {
            print('Error parsing lastLogin: $e');
          }
        }
        
        state = AppUser(
          id: id,
          name: name,
          username: username,
          role: _roleFromString(roleString),
          email: email,
          phone: phone,
          status: status,
          createdAt: createdAt,
          lastLogin: lastLogin,
        );
        
        print('User loaded successfully: ${state?.username}');
      }
    } catch (e) {
      print('Error loading user: $e');
      await _clearUser();
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
    try {
      await _prefs.remove(_userKey);
      state = null;
      print('User data cleared successfully');
    } catch (e) {
      print('Error clearing user: $e');
      state = null;
    }
  }

  // Public method to clear corrupted data
  Future<void> clearCorruptedData() async {
    print('Clearing corrupted user data...');
    await _clearUser();
  }

  // Debug method to check current stored data
  Future<void> debugUserData() async {
    try {
      final userData = _prefs.getString(_userKey);
      if (userData != null) {
        print('Current stored user data: $userData');
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        print('Parsed user map: $userMap');
      } else {
        print('No user data stored');
      }
    } catch (e) {
      print('Error reading user data: $e');
    }
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
      print('Registration error: $e');
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
      print('Login error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      await _clearUser();
      state = null;
    } catch (e) {
      print('Logout error: $e');
      state = null;
    }
  }

  bool get isInitialized => _initialized;
}
