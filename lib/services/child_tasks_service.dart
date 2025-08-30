import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_tasks_model.dart';
import '../models/task_model.dart';

class ChildTasksService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _childTasks =>
      _firestore.collection('child_tasks');

  // Assign task to child
  Future<String> assignTaskToChild(
    String childId,
    String taskId,
    String groupId,
    String assignedBy, {
    String? notes,
  }) async {
    // Check if task is already assigned to this child
    final existing = await _childTasks
        .where('childId', isEqualTo: childId)
        .where('taskId', isEqualTo: taskId)
        .where('groupId', isEqualTo: groupId)
        .where('status', whereIn: ['pending', 'inProgress'])
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('المهمة مسندة بالفعل لهذا الطفل');
    }

    final childTask = ChildTasksModel(
      id: '',
      childId: childId,
      taskId: taskId,
      groupId: groupId,
      assignedAt: DateTime.now(),
      assignedBy: assignedBy,
      notes: notes,
    );

    final doc = await _childTasks.add(childTask.toMap());
    return doc.id;
  }

  // Update task status
  Future<void> updateTaskStatus(
    String id,
    TaskStatus status, {
    double? mark,
    String? notes,
  }) async {
    final updateData = <String, dynamic>{
      'status': status.toString().split('.').last,
    };

    if (mark != null) {
      updateData['mark'] = mark;
    }

    if (notes != null) {
      updateData['notes'] = notes;
    }

    if (status == TaskStatus.completed) {
      updateData['completedAt'] = Timestamp.fromDate(DateTime.now());
    }

    await _childTasks.doc(id).update(updateData);
  }

  // Get tasks for a child
  Future<List<ChildTasksModel>> getTasksForChild(String childId) async {
    final snapshot = await _childTasks
        .where('childId', isEqualTo: childId)
        .orderBy('assignedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ChildTasksModel.fromFirestore(doc))
        .toList();
  }

  // Get tasks for a group
  Future<List<ChildTasksModel>> getTasksForGroup(String groupId) async {
    final snapshot = await _childTasks
        .where('groupId', isEqualTo: groupId)
        .orderBy('assignedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ChildTasksModel.fromFirestore(doc))
        .toList();
  }

  // Get child task by ID
  Future<ChildTasksModel?> getChildTaskById(String id) async {
    final doc = await _childTasks.doc(id).get();
    if (!doc.exists) return null;
    return ChildTasksModel.fromFirestore(doc);
  }

  // Get tasks with task details
  Future<List<Map<String, dynamic>>> getTasksWithDetails(String childId) async {
    final tasks = await getTasksForChild(childId);
    final result = <Map<String, dynamic>>[];

    for (var task in tasks) {
      final taskDoc = await _firestore
          .collection('tasks')
          .doc(task.taskId)
          .get();
      if (taskDoc.exists) {
        final taskModel = TaskModel.fromFirestore(taskDoc);
        result.add({'childTask': task, 'task': taskModel});
      }
    }

    return result;
  }

  // Get child progress statistics
  Future<Map<String, dynamic>> getChildProgress(String childId) async {
    final tasks = await getTasksForChild(childId);

    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = tasks.where((t) => t.isPending).length;
    final inProgressTasks = tasks.where((t) => t.isInProgress).length;

    final totalMarks = tasks
        .where((t) => t.mark != null)
        .fold(0.0, (sum, task) => sum + (task.mark ?? 0));

    final averageMark = tasks.where((t) => t.mark != null).isEmpty
        ? 0.0
        : totalMarks / tasks.where((t) => t.mark != null).length;

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'inProgressTasks': inProgressTasks,
      'completionRate': totalTasks > 0
          ? (completedTasks / totalTasks) * 100
          : 0.0,
      'totalMarks': totalMarks,
      'averageMark': averageMark,
    };
  }

  // Get group progress statistics
  Future<Map<String, dynamic>> getGroupProgress(String groupId) async {
    final tasks = await getTasksForGroup(groupId);

    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = tasks.where((t) => t.isPending).length;
    final inProgressTasks = tasks.where((t) => t.isInProgress).length;

    final totalMarks = tasks
        .where((t) => t.mark != null)
        .fold(0.0, (sum, task) => sum + (task.mark ?? 0));

    final averageMark = tasks.where((t) => t.mark != null).isEmpty
        ? 0.0
        : totalMarks / tasks.where((t) => t.mark != null).length;

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'inProgressTasks': inProgressTasks,
      'completionRate': totalTasks > 0
          ? (completedTasks / totalTasks) * 100
          : 0.0,
      'totalMarks': totalMarks,
      'averageMark': averageMark,
    };
  }

  // Get child ranking in group
  Future<List<Map<String, dynamic>>> getChildRankingInGroup(
    String groupId,
  ) async {
    final tasks = await getTasksForGroup(groupId);

    // Group tasks by child
    final childTasks = <String, List<ChildTasksModel>>{};
    for (var task in tasks) {
      childTasks.putIfAbsent(task.childId, () => []).add(task);
    }

    // Calculate scores for each child
    final childScores = <Map<String, dynamic>>[];
    for (var entry in childTasks.entries) {
      final childId = entry.key;
      final childTaskList = entry.value;

      final completedTasks = childTaskList.where((t) => t.isCompleted).length;
      final totalMarks = childTaskList
          .where((t) => t.mark != null)
          .fold(0.0, (sum, task) => sum + (task.mark ?? 0));

      childScores.add({
        'childId': childId,
        'completedTasks': completedTasks,
        'totalMarks': totalMarks,
        'score':
            totalMarks + (completedTasks * 10), // Bonus points for completion
      });
    }

    // Sort by score (descending)
    childScores.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    // Add ranking
    for (int i = 0; i < childScores.length; i++) {
      childScores[i]['rank'] = i + 1;
    }

    return childScores;
  }

  // Delete child task
  Future<void> deleteChildTask(String id) async {
    await _childTasks.doc(id).delete();
  }

  // Bulk assign tasks to group
  Future<void> bulkAssignTasksToGroup(
    String groupId,
    List<String> taskIds,
    List<String> childIds,
    String assignedBy,
  ) async {
    final batch = _firestore.batch();

    for (var taskId in taskIds) {
      for (var childId in childIds) {
        final childTask = ChildTasksModel(
          id: '',
          childId: childId,
          taskId: taskId,
          groupId: groupId,
          assignedAt: DateTime.now(),
          assignedBy: assignedBy,
        );

        final docRef = _childTasks.doc();
        batch.set(docRef, childTask.toMap());
      }
    }

    await batch.commit();
  }
}
