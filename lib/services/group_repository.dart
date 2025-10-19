import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';
import 'firebase_service.dart';

class GroupRepository {
  final CollectionReference _collection = FirebaseService.groupsRef;

  // Create group
  Future<String> createGroup(Group group) async {
    try {
      final docRef = await _collection.add(group.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  // Add group (alias for createGroup)
  Future<void> addGroup(Group group) async {
    try {
      await _collection.doc(group.id).set(group.toMap());
    } catch (e) {
      throw Exception('Failed to add group: $e');
    }
  }

  // Get all groups
  Stream<List<Group>> getAllGroups() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Group.fromMap(data);
      }).toList();
    });
  }

  // Get group by ID
  Future<Group?> getGroupById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Group.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get group: $e');
    }
  }

  // Update group
  Future<void> updateGroup(Group group) async {
    try {
      await _collection.doc(group.id).update(group.toMap());
    } catch (e) {
      throw Exception('Failed to update group: $e');
    }
  }

  // Delete group
  Future<void> deleteGroup(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  // Update group student count
  Future<void> updateGroupStudentCount(String groupId, int count) async {
    try {
      await _collection.doc(groupId).update({
        'studentCount': FieldValue.increment(count),
        'updatedAt': FirebaseService.currentTimestamp,
      });
    } catch (e) {
      throw Exception('Failed to update group student count: $e');
    }
  }
}
