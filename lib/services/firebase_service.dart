import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/task_model.dart';
import '../models/child_model.dart';
import '../models/assignment_model.dart';
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
  CollectionReference<Map<String, dynamic>> get _assignments => 
      _db.collection(FirestoreCollections.assignments);
  CollectionReference<Map<String, dynamic>> get _attendance => 
      _db.collection(FirestoreCollections.attendance);
  CollectionReference<Map<String, dynamic>> get _childTasks => 
      _db.collection(FirestoreCollections.childTasks);
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
    return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
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
    final snapshot = await _tasks.where('categoryId', isEqualTo: categoryId).get();
    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
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
    final snapshot = await _children.where('parentId', isEqualTo: parentId).get();
    return snapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
  }

  Future<List<ChildModel>> getChildrenBySheikh(String sheikhId) async {
    final assignments = await _assignments
        .where('sheikhId', isEqualTo: sheikhId)
        .where('isActive', isEqualTo: true)
        .get();
    
    final childIds = assignments.docs.map((doc) => doc.data()['childId'] as String).toList();
    
    if (childIds.isEmpty) return [];
    
    final childrenSnapshot = await _children.where(FieldPath.documentId, whereIn: childIds).get();
    return childrenSnapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
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

  // ==================== ASSIGNMENT MANAGEMENT ====================
  
  Future<void> assignChildToCategory(String childId, String categoryId, String sheikhId) async {
    // Deactivate existing assignments for this child
    final existingAssignments = await _assignments
        .where('childId', isEqualTo: childId)
        .where('isActive', isEqualTo: true)
        .get();
    
    for (var doc in existingAssignments.docs) {
      await doc.reference.update({'isActive': false});
    }

    // Create new assignment
    await _assignments.add({
      'childId': childId,
      'categoryId': categoryId,
      'sheikhId': sheikhId,
      'isActive': true,
      'assignedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AssignmentModel?> getActiveAssignment(String childId) async {
    final snapshot = await _assignments
        .where('childId', isEqualTo: childId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return AssignmentModel.fromFirestore(snapshot.docs.first);
  }

  Future<void> unassignChild(String childId) async {
    final assignments = await _assignments
        .where('childId', isEqualTo: childId)
        .where('isActive', isEqualTo: true)
        .get();
    
    for (var doc in assignments.docs) {
      await doc.reference.update({'isActive': false});
    }
  }

  // ==================== ATTENDANCE MANAGEMENT ====================
  
  Future<void> markAttendance(String childId, String date, String status) async {
    await _attendance.add({
      'childId': childId,
      'date': date,
      'status': status,
      'markedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getAttendanceByChild(String childId, String startDate, String endDate) async {
    final snapshot = await _attendance
        .where('childId', isEqualTo: childId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ==================== TASK RESULTS MANAGEMENT ====================
  
  Future<void> submitTaskResult(String childId, String taskId, int points, String? notes) async {
    await _results.add({
      'childId': childId,
      'taskId': taskId,
      'points': points,
      'notes': notes,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getTaskResultsByChild(String childId) async {
    final snapshot = await _results
        .where('childId', isEqualTo: childId)
        .orderBy('submittedAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ==================== STATISTICS ====================
  
  Future<Map<String, dynamic>> getDashboardStats() async {
    // Fetch all collections needed for counts
    final usersSnapshot = await _users.get();
    final sheikhsSnapshot = await _users.where('role', isEqualTo: UserRole.sheikh.name).get();
    final parentsSnapshot = await _users.where('role', isEqualTo: UserRole.parent.name).get();
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
      'activeUsers': usersSnapshot.docs.where((doc) => doc.data()['status'] == 'active').length,
      'activeChildren': childrenSnapshot.docs.where((doc) => doc.data()['isApproved'] == true).length,
    };
  }

  Future<Map<String, dynamic>> getParentStats(String parentId) async {
    final children = await getChildrenByParent(parentId);
    final totalChildren = children.length;
    final approvedChildren = children.where((child) => child.isApproved).length;

    // Get assignments for children to count sheikhs
    final childIds = children.map((child) => child.id).toList();
    int totalSheikhs = 0;
    if (childIds.isNotEmpty) {
      final assignments = await _assignments
          .where('childId', whereIn: childIds)
          .where('isActive', isEqualTo: true)
          .get();
      
      final sheikhIds = assignments.docs.map((doc) => doc.data()['sheikhId'] as String).toSet();
      totalSheikhs = sheikhIds.length;
    }

    return {
      'totalChildren': totalChildren,
      'approvedChildren': approvedChildren,
      'pendingChildren': totalChildren - approvedChildren,
      'totalSheikhs': totalSheikhs,
    };
  }

  Future<Map<String, dynamic>> getSheikhStats(String sheikhId) async {
    final children = await getChildrenBySheikh(sheikhId);
    final assignments = await _assignments
        .where('sheikhId', isEqualTo: sheikhId)
        .where('isActive', isEqualTo: true)
        .get();

    // Get tasks for categories that this sheikh teaches
    final categoryIds = assignments.docs.map((doc) => doc.data()['categoryId'] as String).toSet();
    int activeTasks = 0;
    if (categoryIds.isNotEmpty) {
      final tasks = await _tasks
          .where('categoryId', whereIn: categoryIds.toList())
          .get();
      activeTasks = tasks.docs.length;
    }

    // Get today's date for lesson counting
    // Placeholder for when lessons collection is added

    // Count today's lessons (this would be from a lessons collection)
    int todayLessons = 0; // Placeholder - would need lessons collection

    // Count pending reports (this would be from a reports collection)
    int pendingReports = 0; // Placeholder - would need reports collection

    return {
      'totalStudents': children.length,
      'activeAssignments': assignments.docs.length,
      'activeTasks': activeTasks,
      'todayLessons': todayLessons,
      'pendingReports': pendingReports,
    };
  }

  // ==================== SCHEDULE GROUPS MANAGEMENT ====================
  
  Future<List<ScheduleGroupModel>> getAllScheduleGroups() async {
    final snapshot = await _scheduleGroups.get();
    return snapshot.docs.map((doc) => ScheduleGroupModel.fromFirestore(doc)).toList();
  }

  Future<List<ScheduleGroupModel>> getScheduleGroupsBySheikh(String sheikhId) async {
    final snapshot = await _scheduleGroups.where('sheikhId', isEqualTo: sheikhId).get();
    return snapshot.docs.map((doc) => ScheduleGroupModel.fromFirestore(doc)).toList();
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
    await _children.doc(childId).update({
      'groupId': null,
      'assignedAt': null,
    });
  }

  Future<List<ChildModel>> getChildrenInGroup(String groupId) async {
    final snapshot = await _children.where('groupId', isEqualTo: groupId).get();
    return snapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
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

    // Active assignments by this sheikh
    final assignments = await _assignments
        .where('sheikhId', isEqualTo: sheikhId)
        .where('isActive', isEqualTo: true)
        .get();

    // Completed results for children under this sheikh
    int completedResults = 0;
    if (assignments.docs.isNotEmpty) {
      final childIds = assignments.docs
          .map((a) => a.data()['childId'] as String)
          .toSet()
          .toList();
      if (childIds.isNotEmpty) {
        // Firestore 'whereIn' supports up to 10 items. Split if needed.
        for (var i = 0; i < childIds.length; i += 10) {
          final batch = childIds.sublist(i, i + 10 > childIds.length ? childIds.length : i + 10);
          final resultsSnap = await _results
              .where('childId', whereIn: batch)
              .get();
          completedResults += resultsSnap.docs.length;
        }
      }
    }

    return {
      'totalStudents': totalStudents,
      'activeAssignments': assignments.docs.length,
      'completedResults': completedResults,
      'groupsCount': groupIds.length,
    };
  }

  Future<List<ScheduleGroupModel>> getTodayScheduleGroupsForSheikh(String sheikhId) async {
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
    return groups.where((g) => g.isActive && g.weekDays.contains(todayWd)).toList();
  }

  Future<Map<String, String>> getAttendanceByGroupAndDate(String groupId, String dateISO) async {
    // dateISO format: YYYY-MM-DD
    final children = await getChildrenInGroup(groupId);
    final childIds = children.map((c) => c.id).toList();
    if (childIds.isEmpty) return {};

    final Map<String, String> statusByChild = {};
    for (var i = 0; i < childIds.length; i += 10) {
      final batch = childIds.sublist(i, i + 10 > childIds.length ? childIds.length : i + 10);
      final snap = await _attendance
          .where('childId', whereIn: batch)
          .where('date', isEqualTo: dateISO)
          .get();
      for (final doc in snap.docs) {
        final d = doc.data();
        statusByChild[d['childId'] as String] = d['status'] as String;
      }
    }
    return statusByChild;
  }

  Future<void> markAttendanceForGroup(String groupId, String dateISO, Map<String, String> statusByChild) async {
    // For each child set a record for that date
    final batch = _db.batch();
    statusByChild.forEach((childId, status) {
      final ref = _attendance.doc('${childId}_$dateISO');
      batch.set(ref, {
        'childId': childId,
        'date': dateISO,
        'status': status,
        'markedAt': FieldValue.serverTimestamp(),
        'groupId': groupId,
      });
    });
    await batch.commit();
  }

  // ==================== CHILD TASKS ====================

  Future<void> assignTaskToChild({
    required String childId,
    required String taskId,
    DateTime? dueDate,
  }) async {
    await _childTasks.add({
      'childId': childId,
      'taskId': taskId,
      'status': 'assigned',
      'assignedAt': FieldValue.serverTimestamp(),
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate),
    });
  }

  Future<List<Map<String, dynamic>>> getChildTasks(String childId) async {
    final snap = await _childTasks.where('childId', isEqualTo: childId).get();
    return snap.docs.map((d) => {
      'id': d.id,
      ...d.data(),
    }).toList();
  }

  Future<void> updateChildTaskStatus({
    required String childTaskId,
    required String status,
  }) async {
    await _childTasks.doc(childTaskId).update({
      'status': status,
      if (status == 'completed') 'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
