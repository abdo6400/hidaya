import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'base_controller.dart';

final sheikhsControllerProvider =
    StateNotifierProvider<SheikhsController, AsyncValue<List<AppUser>>>(
  (ref) => SheikhsController(FirebaseService()),
);

class SheikhsController extends BaseController<AppUser> {
  final FirebaseService _firebaseService;

  SheikhsController(this._firebaseService) {
    loadItems();
  }

  @override
  Future<void> loadItems() async {
    setLoading();
    state = await AsyncValue.guard(() => _firebaseService.getUsersByRole(UserRole.sheikh));
  }

  @override
  Future<void> addItem(AppUser item) async {
    // Sheikhs are added through AuthService, not directly
    throw UnsupportedError('Sheikhs should be added through AuthService');
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

  // Additional methods for sheikh management
  Future<List<AppUser>> getActiveSheikhs() async {
    final sheikhs = await _firebaseService.getUsersByRole(UserRole.sheikh);
    return sheikhs.where((sheikh) => sheikh.status == 'active').toList();
  }

  Future<AppUser?> getSheikhById(String sheikhId) async {
    return await _firebaseService.getUserById(sheikhId);
  }

  Future<void> updateSheikhStatus(String sheikhId, String status) async {
    await handleOperation(() => _firebaseService.updateUser(sheikhId, {'status': status}));
  }

  Future<void> activateSheikh(String sheikhId) async {
    await updateSheikhStatus(sheikhId, 'active');
  }

  Future<void> deactivateSheikh(String sheikhId) async {
    await updateSheikhStatus(sheikhId, 'inactive');
  }

  Future<void> blockSheikh(String sheikhId) async {
    await updateSheikhStatus(sheikhId, 'blocked');
  }

  // Legacy method names for backward compatibility
  Future<void> loadSheikhs() => loadItems();
  Future<void> addSheikh(AppUser sheikh) => addItem(sheikh);
  Future<void> updateSheikh(AppUser sheikh) => updateItem(sheikh);
  Future<void> deleteSheikh(String sheikhId) => deleteItem(sheikhId);
}
