import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/child_model.dart';
import '../models/task_model.dart';

// Firebase service provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Dashboard stats provider
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getDashboardStats();
});

// Parent stats provider
final parentStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, parentId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getParentStats(parentId);
});

// Sheikh stats provider
final sheikhStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, sheikhId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getSheikhStats(sheikhId);
});

// Children by parent provider
final childrenByParentProvider = FutureProvider.family<List<ChildModel>, String>((ref, parentId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getChildrenByParent(parentId);
});

// Children by sheikh provider
final childrenBySheikhProvider = FutureProvider.family<List<ChildModel>, String>((ref, sheikhId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getChildrenBySheikh(sheikhId);
});

// Tasks by category provider
final tasksByCategoryProvider = FutureProvider.family<List<TaskModel>, String>((ref, categoryId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getTasksByCategory(categoryId);
});

// Users by role provider
final usersByRoleProvider = FutureProvider.family<List<AppUser>, UserRole>((ref, role) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getUsersByRole(role);
});
