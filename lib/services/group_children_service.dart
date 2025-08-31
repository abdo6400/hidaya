import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_model.dart';
import '../utils/firestore_constants.dart';

class GroupChildrenService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _children => 
      _db.collection(FirestoreCollections.children);
  CollectionReference<Map<String, dynamic>> get _groupChildren => 
      _db.collection('group_children');

  Future<List<ChildModel>> getChildrenInGroup(String groupId) async {
    final snapshot = await _children.where('groupId', isEqualTo: groupId).get();
    return snapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
  }

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

  Future<List<ChildModel>> getAvailableChildren() async {
    final snapshot = await _children.where('groupId', isEqualTo: null).get();
    return snapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
  }

  Future<int> getChildrenCountInGroup(String groupId) async {
    final snapshot = await _children.where('groupId', isEqualTo: groupId).get();
    return snapshot.docs.length;
  }
}
