import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hidaya/services/auth_service.dart';
import '../models/user_model.dart';

class SheiksService {
  SheiksService({FirebaseFirestore? firestore, AuthService? authService})
    : _db = firestore ?? FirebaseFirestore.instance,
      _authService = authService ?? AuthService();

  final FirebaseFirestore _db;
  final AuthService _authService;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  /// Get all sheikhs
  Future<List<AppUser>> getAllSheikhs() async {
    final query = await _users.where('role', isEqualTo: UserRole.sheikh.name).get();
    return query.docs.map((doc) => AppUser.fromDoc(doc)).toList();
  }

  /// Add sheikh (creates user + username index)
  Future<AppUser?> addSheikh({
    required String username,
    required String password,
    required String phone,
    required String status,
  }) async {
    try {
      final user = await _authService.register(
        username: username,
        password: password,
        role: UserRole.sheikh,
        status: status,
        phone: phone,
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Delete sheikh (removes user + username index)
  Future<void> deleteSheikh(String sheikhId) async {
    final snap = await _users.doc(sheikhId).get();
    if (!snap.exists) {
      throw AuthException('not_found', 'Sheikh not found.');
    }
    if (snap.data()?['role'] != UserRole.sheikh.name) {
      throw AuthException('invalid_role', 'This user is not a sheikh.');
    }

    await _authService.deleteAccount(userId: sheikhId);
  }

  /// Update sheikh (e.g. email, phone, username via AuthService)
  Future<void> updateSheikh(String sheikhId, Map<String, dynamic> data) async {
    final snap = await _users.doc(sheikhId).get();
    if (!snap.exists) {
      throw AuthException('not_found', 'Sheikh not found.');
    }
    if (snap.data()?['role'] != UserRole.sheikh.name) {
      throw AuthException('invalid_role', 'This user is not a sheikh.');
    }

    // Prevent role change by mistake
    final safeData = Map<String, dynamic>.from(data);
    safeData.remove('role');

    await _users.doc(sheikhId).update(safeData);
  }

  /// Activate sheikh account
  Future<void> activateSheikh(String sheikhId) async {
    await _setSheikhStatus(sheikhId, 'active');
  }

  /// Deactivate/Block sheikh account
  Future<void> deactivateSheikh(String sheikhId) async {
    await _setSheikhStatus(sheikhId, 'blocked');
  }

  Future<void> _setSheikhStatus(String sheikhId, String status) async {
    final snap = await _users.doc(sheikhId).get();
    if (!snap.exists) {
      throw AuthException('not_found', 'Sheikh not found.');
    }
    if (snap.data()?['role'] != UserRole.sheikh.name) {
      throw AuthException('invalid_role', 'This user is not a sheikh.');
    }

    await _users.doc(sheikhId).update({'status': status});
  }

  // Schedule-related operations have been moved to SchedulesService
  // Use schedulesServiceProvider or schedulesControllerProvider for schedule operations
}
