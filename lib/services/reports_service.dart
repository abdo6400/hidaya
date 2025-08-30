import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_group_model.dart';
import '../models/child_model.dart';
import '../models/task_model.dart';
import '../models/child_tasks_model.dart';
import '../models/user_model.dart';

class ReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get overall statistics
  Future<Map<String, dynamic>> getOverallStatistics() async {
    try {
      // Get total groups
      final groupsSnapshot = await _firestore
          .collection('schedule_groups')
          .where('isActive', isEqualTo: true)
          .get();
      final totalGroups = groupsSnapshot.docs.length;
      final activeGroups = groupsSnapshot.docs.length;

      // Get total children
      final childrenSnapshot = await _firestore.collection('children').get();
      final totalChildren = childrenSnapshot.docs.length;

      // Get total tasks
      final tasksSnapshot = await _firestore.collection('tasks').get();
      final totalTasks = tasksSnapshot.docs.length;

      // Get total sheikhs
      final sheikhsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'sheikh')
          .get();
      final totalSheikhs = sheikhsSnapshot.docs.length;

      // Get total child tasks
      final childTasksSnapshot = await _firestore
          .collection('child_tasks')
          .get();
      final totalChildTasks = childTasksSnapshot.docs.length;

      // Get completed tasks
      final completedTasksSnapshot = await _firestore
          .collection('child_tasks')
          .where('status', isEqualTo: 'completed')
          .get();
      final completedTasks = completedTasksSnapshot.docs.length;

      // Calculate completion rate
      final completionRate = totalChildTasks > 0
          ? (completedTasks / totalChildTasks) * 100
          : 0.0;

      return {
        'totalGroups': totalGroups,
        'activeGroups': activeGroups,
        'totalChildren': totalChildren,
        'totalTasks': totalTasks,
        'totalSheikhs': totalSheikhs,
        'totalChildTasks': totalChildTasks,
        'completedTasks': completedTasks,
        'completionRate': completionRate,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  // Get group performance statistics
  Future<List<Map<String, dynamic>>> getGroupPerformance() async {
    try {
      final groupsSnapshot = await _firestore
          .collection('schedule_groups')
          .where('isActive', isEqualTo: true)
          .get();

      final List<Map<String, dynamic>> groupStats = [];

      for (var groupDoc in groupsSnapshot.docs) {
        final group = ScheduleGroupModel.fromFirestore(groupDoc);

        // Get children in this group
        final groupChildrenSnapshot = await _firestore
            .collection('group_children')
            .where('groupId', isEqualTo: group.id)
            .where('isActive', isEqualTo: true)
            .get();

        final childrenCount = groupChildrenSnapshot.docs.length;

        // Get tasks for this group
        final groupTasksSnapshot = await _firestore
            .collection('child_tasks')
            .where('groupId', isEqualTo: group.id)
            .get();

        final totalTasks = groupTasksSnapshot.docs.length;
        final completedTasks = groupTasksSnapshot.docs
            .where((doc) => doc.data()['status'] == 'completed')
            .length;

        final completionRate = totalTasks > 0
            ? (completedTasks / totalTasks) * 100
            : 0.0;

        // Get average marks
        final tasksWithMarks = groupTasksSnapshot.docs
            .where((doc) => doc.data()['mark'] != null)
            .toList();

        final totalMarks = tasksWithMarks.fold<double>(
          0.0,
          (sum, doc) => sum + (doc.data()['mark'] as double),
        );

        final averageMark = tasksWithMarks.isNotEmpty
            ? totalMarks / tasksWithMarks.length
            : 0.0;

        groupStats.add({
          'groupId': group.id,
          'groupName': group.name,
          'sheikhId': group.sheikhId,
          'childrenCount': childrenCount,
          'totalTasks': totalTasks,
          'completedTasks': completedTasks,
          'completionRate': completionRate,
          'averageMark': averageMark,
        });
      }

      return groupStats;
    } catch (e) {
      throw Exception('Failed to get group performance: $e');
    }
  }

  // Get child performance statistics
  Future<List<Map<String, dynamic>>> getChildPerformance() async {
    try {
      final childrenSnapshot = await _firestore.collection('children').get();
      final List<Map<String, dynamic>> childStats = [];

      for (var childDoc in childrenSnapshot.docs) {
        final child = ChildModel.fromDoc(childDoc);

        // Get tasks for this child
        final childTasksSnapshot = await _firestore
            .collection('child_tasks')
            .where('childId', isEqualTo: child.id)
            .get();

        final totalTasks = childTasksSnapshot.docs.length;
        final completedTasks = childTasksSnapshot.docs
            .where((doc) => doc.data()['status'] == 'completed')
            .length;

        final completionRate = totalTasks > 0
            ? (completedTasks / totalTasks) * 100
            : 0.0;

        // Get average marks
        final tasksWithMarks = childTasksSnapshot.docs
            .where((doc) => doc.data()['mark'] != null)
            .toList();

        final totalMarks = tasksWithMarks.fold<double>(
          0.0,
          (sum, doc) => sum + (doc.data()['mark'] as double),
        );

        final averageMark = tasksWithMarks.isNotEmpty
            ? totalMarks / tasksWithMarks.length
            : 0.0;

        // Get groups for this child
        final childGroupsSnapshot = await _firestore
            .collection('group_children')
            .where('childId', isEqualTo: child.id)
            .where('isActive', isEqualTo: true)
            .get();

        final groupsCount = childGroupsSnapshot.docs.length;

        childStats.add({
          'childId': child.id,
          'childName': child.name,
          'age': child.age,
          'parentId': child.parentId,
          'totalTasks': totalTasks,
          'completedTasks': completedTasks,
          'completionRate': completionRate,
          'averageMark': averageMark,
          'groupsCount': groupsCount,
        });
      }

      return childStats;
    } catch (e) {
      throw Exception('Failed to get child performance: $e');
    }
  }

  // Get sheikh performance statistics
  Future<List<Map<String, dynamic>>> getSheikhPerformance() async {
    try {
      final sheikhsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'sheikh')
          .get();

      final List<Map<String, dynamic>> sheikhStats = [];

      for (var sheikhDoc in sheikhsSnapshot.docs) {
        final sheikh = AppUser.fromDoc(sheikhDoc);

        // Get groups for this sheikh
        final sheikhGroupsSnapshot = await _firestore
            .collection('schedule_groups')
            .where('sheikhId', isEqualTo: sheikh.id)
            .where('isActive', isEqualTo: true)
            .get();

        final groupsCount = sheikhGroupsSnapshot.docs.length;

        // Get total children for this sheikh
        int totalChildren = 0;
        for (var groupDoc in sheikhGroupsSnapshot.docs) {
          final groupChildrenSnapshot = await _firestore
              .collection('group_children')
              .where('groupId', isEqualTo: groupDoc.id)
              .where('isActive', isEqualTo: true)
              .get();
          totalChildren += groupChildrenSnapshot.docs.length;
        }

        // Get tasks for this sheikh's groups
        int totalTasks = 0;
        int completedTasks = 0;
        double totalMarks = 0.0;
        int tasksWithMarks = 0;

        for (var groupDoc in sheikhGroupsSnapshot.docs) {
          final groupTasksSnapshot = await _firestore
              .collection('child_tasks')
              .where('groupId', isEqualTo: groupDoc.id)
              .get();

          totalTasks += groupTasksSnapshot.docs.length;
          completedTasks += groupTasksSnapshot.docs
              .where((doc) => doc.data()['status'] == 'completed')
              .length;

          for (var taskDoc in groupTasksSnapshot.docs) {
            if (taskDoc.data()['mark'] != null) {
              totalMarks += taskDoc.data()['mark'] as double;
              tasksWithMarks++;
            }
          }
        }

        final completionRate = totalTasks > 0
            ? (completedTasks / totalTasks) * 100
            : 0.0;

        final averageMark = tasksWithMarks > 0
            ? totalMarks / tasksWithMarks
            : 0.0;

        sheikhStats.add({
          'sheikhId': sheikh.id,
          'sheikhName': sheikh.username,
          'groupsCount': groupsCount,
          'totalChildren': totalChildren,
          'totalTasks': totalTasks,
          'completedTasks': completedTasks,
          'completionRate': completionRate,
          'averageMark': averageMark,
        });
      }

      return sheikhStats;
    } catch (e) {
      throw Exception('Failed to get sheikh performance: $e');
    }
  }

  // Get recent activity
  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    try {
      final List<Map<String, dynamic>> activities = [];

      // Get recent child tasks
      final recentTasksSnapshot = await _firestore
          .collection('child_tasks')
          .orderBy('assignedAt', descending: true)
          .limit(10)
          .get();

      for (var taskDoc in recentTasksSnapshot.docs) {
        final taskData = taskDoc.data();
        final childId = taskData['childId'] as String;
        final taskId = taskData['taskId'] as String;
        final status = taskData['status'] as String;
        final assignedAt = (taskData['assignedAt'] as Timestamp).toDate();

        // Get child name
        final childDoc = await _firestore
            .collection('children')
            .doc(childId)
            .get();
        final childName = childDoc.exists && childDoc.data() != null
            ? (childDoc.data()!['name'] as String?) ?? 'Unknown'
            : 'Unknown';

        // Get task title
        final taskTitleDoc = await _firestore
            .collection('tasks')
            .doc(taskId)
            .get();
        final taskTitle = taskTitleDoc.exists && taskTitleDoc.data() != null
            ? (taskTitleDoc.data()!['title'] as String?) ?? 'Unknown'
            : 'Unknown';

        activities.add({
          'type': 'task',
          'action': status == 'completed' ? 'completed_task' : 'assigned_task',
          'childName': childName,
          'taskTitle': taskTitle,
          'timestamp': assignedAt,
          'status': status,
        });
      }

      // Get recent group assignments
      final recentAssignmentsSnapshot = await _firestore
          .collection('group_children')
          .orderBy('assignedAt', descending: true)
          .limit(5)
          .get();

      for (var assignmentDoc in recentAssignmentsSnapshot.docs) {
        final assignmentData = assignmentDoc.data();
        final childId = assignmentData['childId'] as String;
        final groupId = assignmentData['groupId'] as String;
        final assignedAt = (assignmentData['assignedAt'] as Timestamp).toDate();

        // Get child name
        final childDoc = await _firestore
            .collection('children')
            .doc(childId)
            .get();
        final childName = childDoc.exists && childDoc.data() != null
            ? (childDoc.data()!['name'] as String?) ?? 'Unknown'
            : 'Unknown';

        // Get group name
        final groupDoc = await _firestore
            .collection('schedule_groups')
            .doc(groupId)
            .get();
        final groupName = groupDoc.exists && groupDoc.data() != null
            ? (groupDoc.data()!['name'] as String?) ?? 'Unknown'
            : 'Unknown';

        activities.add({
          'type': 'assignment',
          'action': 'assigned_to_group',
          'childName': childName,
          'groupName': groupName,
          'timestamp': assignedAt,
        });
      }

      // Sort by timestamp
      activities.sort(
        (a, b) =>
            (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
      );

      return activities.take(15).toList();
    } catch (e) {
      throw Exception('Failed to get recent activity: $e');
    }
  }

  // Get monthly statistics
  Future<Map<String, dynamic>> getMonthlyStatistics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      // Get tasks completed this month
      final monthlyTasksSnapshot = await _firestore
          .collection('child_tasks')
          .where(
            'completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'completedAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
          )
          .where('status', isEqualTo: 'completed')
          .get();

      final monthlyCompletedTasks = monthlyTasksSnapshot.docs.length;

      // Get new children this month
      final monthlyChildrenSnapshot = await _firestore
          .collection('children')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
          )
          .get();

      final monthlyNewChildren = monthlyChildrenSnapshot.docs.length;

      // Get new groups this month
      final monthlyGroupsSnapshot = await _firestore
          .collection('schedule_groups')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
          )
          .get();

      final monthlyNewGroups = monthlyGroupsSnapshot.docs.length;

      return {
        'month': '${now.month}/${now.year}',
        'completedTasks': monthlyCompletedTasks,
        'newChildren': monthlyNewChildren,
        'newGroups': monthlyNewGroups,
      };
    } catch (e) {
      throw Exception('Failed to get monthly statistics: $e');
    }
  }
}
