import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hidaya/models/user_model.dart';
import '../models/child_model.dart';
import '../services/auth_service.dart';

class ParentsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  // ------------------- CHILDREN -------------------

  Future<List<ChildModel>> getAllChildren() async {
    final snapshot = await _db.collection("children").get();
    return snapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
  }

  Future<List<ChildModel>> getChildrenByParent(String parentId) async {
    final snapshot = await _db.collection("children").where("parentId", isEqualTo: parentId).get();
    return snapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
  }

  Future<void> addChild({
    required String name,
    required String parentId,
    required String createdBy, // "parent" | "admin"
    required String age,
  }) async {
    await _db.collection("children").add({
      "name": name,
      "parentId": parentId,
      "isApproved": createdBy == "admin",
      "createdBy": createdBy,
      "createdAt": FieldValue.serverTimestamp(),
      "age": age,
    });
  }

  Future<void> approveChild(String childId) async {
    await _db.collection("children").doc(childId).update({"isApproved": true});
  }

  Future<void> updateChild(String childId, Map<String, dynamic> data) async {
    await _db.collection("children").doc(childId).update(data);
  }

  Future<void> deleteChild(String childId) async {
    await _db.collection("children").doc(childId).delete();
  }

  // ------------------- PARENTS -------------------

  Future<List<AppUser>> getParents() async {
    final snapshot = await _users.where("role", isEqualTo: UserRole.parent.name).get();
    return snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList();
  }

  Future<void> addParent(AppUser parent, String password) async {
    await _authService.register(
      username: parent.username,
      password: password,
      role: UserRole.parent,
      email: parent.email,
      phone: parent.phone,
      status: "active",
    );
  }

  Future<void> updateParent(AppUser parent) async {
    await _authService.changeUsername(userId: parent.id, newUsername: parent.username);
  }

  Future<void> updateParentStatus(String parentId, String status) async {
    await _users.doc(parentId).update({'status': status});
  }

  Future<void> changeParentPassword(AppUser parent, String oldPassword, String newPassword) async {
    await _authService.changePassword(
      userId: parent.id,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  Future<void> deleteParent(String parentId) async {
    await _authService.deleteAccount(userId: parentId);
  }
}
