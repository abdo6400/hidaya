import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/child_model.dart';
import '../models/schedule_group_model.dart';
import '../models/task_model.dart';
import '../models/task_result_model.dart';

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


// Children by parent provider
final childrenByParentProvider = FutureProvider.family<List<ChildModel>, String>((ref, parentId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getChildrenByParent(parentId);
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

// Sheikh home stats provider
final sheikhHomeStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, sheikhId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getSheikhHomeStats(sheikhId);
});

// Sheikh today schedule groups provider
final sheikhTodayGroupsProvider = FutureProvider.family<List<ScheduleGroupModel>, String>((ref, sheikhId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getTodayScheduleGroupsForSheikh(sheikhId);
});

// All schedule groups for a sheikh
final sheikhGroupsProvider = FutureProvider.family<List<ScheduleGroupModel>, String>((ref, sheikhId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getScheduleGroupsBySheikh(sheikhId);
});

// All schedule groups provider
final allScheduleGroupsProvider = FutureProvider<List<ScheduleGroupModel>>((ref) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getAllScheduleGroups();
});

// Group students provider
final childrenInGroupProvider = FutureProvider.family<List<ChildModel>, String>((ref, groupId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getChildrenInGroup(groupId);
});



// Tasks available for a group: category-specific + global (categoryId == null)
final tasksForGroupProvider = FutureProvider.family<List<TaskModel>, String>((ref, groupId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  final group = await firebaseService.getScheduleGroupById(groupId);
  if (group == null) return [];
  final all = await firebaseService.getAllTasks();
  final List<TaskModel> categoryTasks = all.where((t) => t.categoryId == group.categoryId).toList();
  final List<TaskModel> globalTasks = all.where((t) => t.categoryId == null || (t.categoryId != null && t.categoryId!.isEmpty)).toList();
  return [...categoryTasks, ...globalTasks];
});

// Task results by child provider
final taskResultsByChildProvider = FutureProvider.family<List<TaskResultModel>, String>((ref, childId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getTaskResultsByChild(childId);
});

// Schedule groups by child provider
final scheduleGroupsByChildProvider = FutureProvider.family<List<ScheduleGroupModel>, String>((ref, childId) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getScheduleGroupsByChild(childId);
});
