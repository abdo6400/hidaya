import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_children_model.dart';
import '../models/child_model.dart';

class GroupChildrenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _groupChildren =>
      _firestore.collection('group_children');

  // Assign child to group
  Future<String> assignChildToGroup(
    String groupId,
    String childId, {
    String? notes,
  }) async {
    // Check if child is already assigned to this group
    final existing = await _groupChildren
        .where('groupId', isEqualTo: groupId)
        .where('childId', isEqualTo: childId)
        .where('isActive', isEqualTo: true)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('الطفل مسجل بالفعل في هذه المجموعة');
    }

    final assignment = GroupChildrenModel(
      id: '',
      groupId: groupId,
      childId: childId,
      assignedAt: DateTime.now(),
      notes: notes,
    );

    final doc = await _groupChildren.add(assignment.toMap());
    return doc.id;
  }

  // Remove child from group
  Future<void> removeChildFromGroup(String groupId, String childId) async {
    final snapshot = await _groupChildren
        .where('groupId', isEqualTo: groupId)
        .where('childId', isEqualTo: childId)
        .where('isActive', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('الطفل غير مسجل في هذه المجموعة');
    }

    await _groupChildren.doc(snapshot.docs.first.id).update({
      'isActive': false,
    });
  }

  // Get children in a group
  Future<List<ChildModel>> getChildrenInGroup(String groupId) async {
    final snapshot = await _groupChildren
        .where('groupId', isEqualTo: groupId)
        .where('isActive', isEqualTo: true)
        .get();

    final childIds = snapshot.docs
        .map((doc) => doc.data()['childId'] as String)
        .toList();

    if (childIds.isEmpty) return [];

    final childrenSnapshot = await _firestore
        .collection('children')
        .where(FieldPath.documentId, whereIn: childIds)
        .get();

    return childrenSnapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
  }

  // Get groups for a child
  Future<List<String>> getGroupsForChild(String childId) async {
    final snapshot = await _groupChildren
        .where('childId', isEqualTo: childId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()['groupId'] as String).toList();
  }

  // Get group assignment by ID
  Future<GroupChildrenModel?> getGroupAssignmentById(String id) async {
    final doc = await _groupChildren.doc(id).get();
    if (!doc.exists) return null;
    return GroupChildrenModel.fromFirestore(doc);
  }

  // Update group assignment notes
  Future<void> updateGroupAssignmentNotes(String id, String notes) async {
    await _groupChildren.doc(id).update({'notes': notes});
  }

  // Get all active assignments
  Future<List<GroupChildrenModel>> getAllActiveAssignments() async {
    final snapshot = await _groupChildren
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => GroupChildrenModel.fromFirestore(doc))
        .toList();
  }

  // Get assignments by group
  Future<List<GroupChildrenModel>> getAssignmentsByGroup(String groupId) async {
    final snapshot = await _groupChildren
        .where('groupId', isEqualTo: groupId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => GroupChildrenModel.fromFirestore(doc))
        .toList();
  }

  // Get assignments by child
  Future<List<GroupChildrenModel>> getAssignmentsByChild(String childId) async {
    final snapshot = await _groupChildren
        .where('childId', isEqualTo: childId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => GroupChildrenModel.fromFirestore(doc))
        .toList();
  }

  // Check if child is in group
  Future<bool> isChildInGroup(String childId, String groupId) async {
    final snapshot = await _groupChildren
        .where('childId', isEqualTo: childId)
        .where('groupId', isEqualTo: groupId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get children count in group
  Future<int> getChildrenCountInGroup(String groupId) async {
    final snapshot = await _groupChildren
        .where('groupId', isEqualTo: groupId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.length;
  }
}
