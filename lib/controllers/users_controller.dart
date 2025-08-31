import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'base_controller.dart';

final usersControllerProvider =
    StateNotifierProvider<UsersController, AsyncValue<List<AppUser>>>(
  (ref) => UsersController(FirebaseService()),
);

class UsersController extends BaseController<AppUser> {
  final FirebaseService _firebaseService;

  UsersController(this._firebaseService) {
    loadItems();
  }

  @override
  Future<void> loadItems() async {
    setLoading();
    state = await AsyncValue.guard(() => _firebaseService.getAllUsers());
  }

  @override
  Future<void> addItem(AppUser item) async {
    // Users are added through AuthService, not directly
    throw UnsupportedError('Users should be added through AuthService');
  }

  @override
  Future<void> updateItem(AppUser item) async {
    // Create update map without password field for security
    final updateData = {
      'name': item.name,
      'username': item.username,
      'role': item.role.name,
      'email': item.email,
      'phone': item.phone,
      'status': item.status,
    };
    await handleOperation(() => _firebaseService.updateUser(item.id, updateData));
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await handleOperation(() => _firebaseService.deleteUser(itemId));
  }

  // Additional methods for user management
  Future<List<AppUser>> getUsersByRole(UserRole role) async {
    return await _firebaseService.getUsersByRole(role);
  }

  Future<AppUser?> getUserById(String userId) async {
    return await _firebaseService.getUserById(userId);
  }

  Future<void> updateUserStatus(String userId, String status) async {
    await handleOperation(() => _firebaseService.updateUser(userId, {'status': status}));
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    await handleOperation(() => _firebaseService.updateUser(userId, data));
  }

  Future<void> activateUser(String userId) async {
    await updateUserStatus(userId, 'active');
  }

  Future<void> deactivateUser(String userId) async {
    await updateUserStatus(userId, 'inactive');
  }

  Future<void> blockUser(String userId) async {
    await updateUserStatus(userId, 'blocked');
  }

  // Legacy method names for backward compatibility
  Future<void> loadUsers() => loadItems();
  Future<void> updateUser(AppUser user) => updateItem(user);
  Future<void> deleteUser(String userId) => deleteItem(userId);
}
