import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/task_model.dart';
import '../models/task_result_model.dart';
import '../models/child_model.dart';
import '../models/schedule_group_model.dart';
import '../models/schedule_model.dart';
import '../utils/firestore_constants.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(FirestoreCollections.users);
  CollectionReference<Map<String, dynamic>> get _categories =>
      _db.collection(FirestoreCollections.categories);
  CollectionReference<Map<String, dynamic>> get _tasks =>
      _db.collection(FirestoreCollections.tasks);
  CollectionReference<Map<String, dynamic>> get _children =>
      _db.collection(FirestoreCollections.children);
  CollectionReference<Map<String, dynamic>> get _results =>
      _db.collection(FirestoreCollections.results);
  CollectionReference<Map<String, dynamic>> get _scheduleGroups =>
      _db.collection(FirestoreCollections.scheduleGroups);

  // ==================== USER MANAGEMENT ====================

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _users.get();
    return snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList();
  }

  Future<List<AppUser>> getUsersByRole(UserRole role) async {
    final snapshot = await _users.where('role', isEqualTo: role.name).get();
    return snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList();
  }

  Future<AppUser?> getUserById(String userId) async {
    final doc = await _users.doc(userId).get();
    if (doc.exists) {
      return AppUser.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _users.doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUser(String userId) async {
    await _users.doc(userId).delete();
  }

  // ==================== CATEGORY MANAGEMENT ====================

  Future<List<CategoryModel>> getAllCategories() async {
    final snapshot = await _categories.get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categories.add(category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categories.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categories.doc(categoryId).delete();
  }

  // ==================== TASK MANAGEMENT ====================

  Future<List<TaskModel>> getAllTasks() async {
    final snapshot = await _tasks.get();
    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
  }

  Future<List<TaskModel>> getTasksByCategory(String categoryId) async {
    final withCategory = await _tasks
        .where('categoryId', isEqualTo: categoryId)
        .get();
    final withoutCategory = await _tasks
        .where('categoryId', isNull: true)
        .get();

    return [
      ...withCategory.docs.map((doc) => TaskModel.fromFirestore(doc)),
      ...withoutCategory.docs.map((doc) => TaskModel.fromFirestore(doc)),
    ];
  }

  Future<void> addTask(TaskModel task) async {
    await _tasks.add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    await _tasks.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasks.doc(taskId).delete();
  }

  // ==================== CHILDREN MANAGEMENT ====================

  Future<List<ChildModel>> getAllChildren() async {
    final snapshot = await _children.get();
    return snapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
  }

  Future<List<ChildModel>> getChildrenByParent(String parentId) async {
    final snapshot = await _children
        .where('parentId', isEqualTo: parentId)
        .get();
    return snapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
  }

  Future<void> addChild(ChildModel child) async {
    await _children.add(child.toMap());
  }

  Future<void> updateChild(String childId, Map<String, dynamic> data) async {
    await _children.doc(childId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteChild(String childId) async {
    await _children.doc(childId).delete();
  }

  // ==================== TASK RESULTS MANAGEMENT ====================

  Future<void> submitTaskResult(
    String childId,
    String taskId,
    int points,
    String? notes, {
    String? dateISO,
    String? groupId,
    String? categoryId,
    String? sheikhId,
    String? taskTitle,
    String? taskType,
    int? maxPoints,
  }) async {
    final String date =
        dateISO ?? DateTime.now().toIso8601String().substring(0, 10);

    // Upsert behavior: if a result exists for the same child, task, and date, update it; otherwise create.
    final existingSnap = await _results
        .where('childId', isEqualTo: childId)
        .where('taskId', isEqualTo: taskId)
        .where('date', isEqualTo: date)
        .limit(1)
        .get();

    final data = {
      'childId': childId,
      'taskId': taskId,
      'points': points,
      'notes': notes,
      'date': date,
      'groupId': groupId,
      'categoryId': categoryId,
      'sheikhId': sheikhId,
      'taskTitle': taskTitle,
      'taskType': taskType,
      'maxPoints': maxPoints,
      'submittedAt': FieldValue.serverTimestamp(),
    };

    if (existingSnap.docs.isNotEmpty) {
      await existingSnap.docs.first.reference.update(data);
    } else {
      await _results.add(data);
    }
  }

  Future<List<TaskResultModel>> getTaskResultsByChild(String childId) async {
    final snapshot = await _results
        .where('childId', isEqualTo: childId)
        .orderBy('submittedAt', descending: true)
        .get();
    return snapshot.docs
        .map(
          (doc) => TaskResultModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();
  }

  Future<Map<String, TaskResultModel>> getTodayResultsByChildAndTask(
    String childId,
  ) async {
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    final snapshot = await _results
        .where('childId', isEqualTo: childId)
        .where('date', isEqualTo: today)
        .get();
    final Map<String, TaskResultModel> byTaskId = {};
    for (final doc in snapshot.docs) {
      final model = TaskResultModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>,
      );
      byTaskId[model.taskId] = model;
    }
    return byTaskId;
  }

  // Helper: get task by id for metadata (type/maxPoints)
  Future<TaskModel?> getTaskById(String taskId) async {
    final doc = await _tasks.doc(taskId).get();
    if (!doc.exists) return null;
    return TaskModel.fromFirestore(doc);
  }

  // ==================== STATISTICS ====================

  Future<Map<String, dynamic>> getDashboardStats() async {
    // Fetch all collections needed for counts
    final usersSnapshot = await _users.get();
    final sheikhsSnapshot = await _users
        .where('role', isEqualTo: UserRole.sheikh.name)
        .get();
    final parentsSnapshot = await _users
        .where('role', isEqualTo: UserRole.parent.name)
        .get();
    final categoriesSnapshot = await _categories.get();
    final childrenSnapshot = await _children.get();
    final tasksSnapshot = await _tasks.get();

    return {
      'totalUsers': usersSnapshot.docs.length,
      'totalSheikhs': sheikhsSnapshot.docs.length,
      'totalParents': parentsSnapshot.docs.length,
      'totalCategories': categoriesSnapshot.docs.length,
      'totalChildren': childrenSnapshot.docs.length,
      'totalTasks': tasksSnapshot.docs.length,
      'activeUsers': usersSnapshot.docs
          .where((doc) => doc.data()['status'] == 'active')
          .length,
      'activeChildren': childrenSnapshot.docs
          .where((doc) => doc.data()['isApproved'] == true)
          .length,
    };
  }

  Future<Map<String, dynamic>> getParentStats(String parentId) async {
    final children = await getChildrenByParent(parentId);
    final totalChildren = children.length;
    final approvedChildren = children.where((child) => child.isApproved).length;

    // Get assignments for children to count sheikhs
    final childIds = children.map((child) => child.id).toList();
    int totalSheikhs = 0;

    return {
      'totalChildren': totalChildren,
      'approvedChildren': approvedChildren,
      'pendingChildren': totalChildren - approvedChildren,
      'totalSheikhs': totalSheikhs,
    };
  }

  // ==================== SCHEDULE GROUPS MANAGEMENT ====================

  Future<List<ScheduleGroupModel>> getAllScheduleGroups() async {
    final snapshot = await _scheduleGroups.get();
    return snapshot.docs
        .map((doc) => ScheduleGroupModel.fromFirestore(doc))
        .toList();
  }

  Future<List<ScheduleGroupModel>> getScheduleGroupsBySheikh(
    String sheikhId,
  ) async {
    final snapshot = await _scheduleGroups
        .where('sheikhId', isEqualTo: sheikhId)
        .get();
    return snapshot.docs
        .map((doc) => ScheduleGroupModel.fromFirestore(doc))
        .toList();
  }

  Future<ScheduleGroupModel?> getScheduleGroupById(String groupId) async {
    final doc = await _scheduleGroups.doc(groupId).get();
    if (doc.exists) {
      return ScheduleGroupModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> addScheduleGroup(ScheduleGroupModel group) async {
    await _scheduleGroups.add(group.toMap());
  }

  Future<void> updateScheduleGroup(ScheduleGroupModel group) async {
    await _scheduleGroups.doc(group.id).update(group.toMap());
  }

  Future<void> deleteScheduleGroup(String groupId) async {
    await _scheduleGroups.doc(groupId).delete();
  }

  // ==================== GROUP CHILDREN MANAGEMENT ====================

  Future<void> assignChildToGroup(String childId, String groupId) async {
    await _children.doc(childId).update({
      'groupId': groupId,
      'assignedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeChildFromGroup(String childId, String groupId) async {
    await _children.doc(childId).update({'groupId': null, 'assignedAt': null});
  }

  Future<List<ChildModel>> getChildrenInGroup(String groupId) async {
    final snapshot = await _children.where('groupId', isEqualTo: groupId).get();
    return snapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
  }

  Future<List<ScheduleGroupModel>> getScheduleGroupsByChild(String childId) async {
    // First get the child to find their groupId
    final childDoc = await _children.doc(childId).get();
    if (!childDoc.exists) return [];
    
    final childData = childDoc.data()!;
    final groupId = childData['groupId'] as String?;
    
    if (groupId == null) return [];
    
    // Get the group
    final groupDoc = await _scheduleGroups.doc(groupId).get();
    if (!groupDoc.exists) return [];
    
    return [ScheduleGroupModel.fromFirestore(groupDoc)];
  }

  // ==================== SHEIKH FEATURES ====================

  Future<Map<String, dynamic>> getSheikhHomeStats(String sheikhId) async {
    // Groups taught by sheikh
    final groups = await getScheduleGroupsBySheikh(sheikhId);
    final groupIds = groups.map((g) => g.id).toList();

    // Children in sheikh's groups
    int totalStudents = 0;
    if (groupIds.isNotEmpty) {
      for (final gid in groupIds) {
        final students = await getChildrenInGroup(gid);
        totalStudents += students.length;
      }
    }

    return {'totalStudents': totalStudents, 'groupsCount': groupIds.length};
  }

  Future<List<ScheduleGroupModel>> getTodayScheduleGroupsForSheikh(
    String sheikhId,
  ) async {
    final groups = await getScheduleGroupsBySheikh(sheikhId);
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Mon .. 7=Sun
    WeekDay toWeekDay(int w) {
      switch (w) {
        case DateTime.monday:
          return WeekDay.monday;
        case DateTime.tuesday:
          return WeekDay.tuesday;
        case DateTime.wednesday:
          return WeekDay.wednesday;
        case DateTime.thursday:
          return WeekDay.thursday;
        case DateTime.friday:
          return WeekDay.friday;
        case DateTime.saturday:
          return WeekDay.saturday;
        default:
          return WeekDay.sunday;
      }
    }

    final todayWd = toWeekDay(weekday);
    return groups
        .where((g) => g.isActive && g.weekDays.contains(todayWd))
        .toList();
  }
}
