import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_assignment_model.dart';

class GroupAssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection('group_assignments');

  // Create a new group assignment
  Future<String> createGroupAssignment(GroupAssignmentModel group) async {
    final doc = await _groups.add(group.toMap());
    return doc.id;
  }

  // Get all active groups
  Future<List<GroupAssignmentModel>> getActiveGroups() async {
    final snapshot = await _groups.where('isActive', isEqualTo: true).get();
    return snapshot.docs
        .map((doc) => GroupAssignmentModel.fromFirestore(doc))
        .toList();
  }

  // Get groups by sheikh
  Future<List<GroupAssignmentModel>> getGroupsBySheikh(String sheikhId) async {
    final snapshot = await _groups
        .where('sheikhId', isEqualTo: sheikhId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => GroupAssignmentModel.fromFirestore(doc))
        .toList();
  }

  // Get groups by schedule
  Future<List<GroupAssignmentModel>> getGroupsBySchedule(String scheduleId) async {
    final snapshot = await _groups
        .where('scheduleId', isEqualTo: scheduleId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => GroupAssignmentModel.fromFirestore(doc))
        .toList();
  }

  // Update group
  Future<void> updateGroup(String groupId, GroupAssignmentModel group) async {
    await _groups.doc(groupId).update(group.toMap());
  }

  // Add children to group
  Future<void> addChildrenToGroup(String groupId, List<String> childrenIds) async {
    await _groups.doc(groupId).update({
      'childrenIds': FieldValue.arrayUnion(childrenIds),
    });
  }

  // Remove children from group
  Future<void> removeChildrenFromGroup(
      String groupId, List<String> childrenIds) async {
    await _groups.doc(groupId).update({
      'childrenIds': FieldValue.arrayRemove(childrenIds),
    });
  }

  // Delete group (soft delete)
  Future<void> deleteGroup(String groupId) async {
    await _groups.doc(groupId).update({'isActive': false});
  }
}
