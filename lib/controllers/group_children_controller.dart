import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_model.dart';
import '../services/firebase_service.dart';
import 'base_controller.dart';

final groupChildrenControllerProvider =
    StateNotifierProvider<GroupChildrenController, AsyncValue<List<ChildModel>>>(
  (ref) => GroupChildrenController(FirebaseService()),
);

final allChildrenControllerProvider =
    StateNotifierProvider<AllChildrenController, AsyncValue<List<ChildModel>>>(
  (ref) => AllChildrenController(FirebaseService()),
);

class GroupChildrenController extends BaseController<ChildModel> {
  final FirebaseService _firebaseService;

  GroupChildrenController(this._firebaseService) {
    loadItems();
  }

  @override
  Future<void> loadItems() async {
    setLoading();
    state = await AsyncValue.guard(() => _firebaseService.getAllChildren());
  }

  @override
  Future<void> addItem(ChildModel item) async {
    await handleOperation(() => _firebaseService.addChild(item));
  }

  @override
  Future<void> updateItem(ChildModel item) async {
    await handleOperation(() => _firebaseService.updateChild(item.id, item.toMap()));
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await handleOperation(() => _firebaseService.deleteChild(itemId));
  }

  Future<void> assignChildToGroup({required String childId, required String groupId}) async {
    await handleOperation(() => _firebaseService.assignChildToGroup(childId, groupId));
  }

  Future<void> removeChildFromGroup({required String childId, required String groupId}) async {
    await handleOperation(() => _firebaseService.removeChildFromGroup(childId, groupId));
  }

  Future<List<ChildModel>> getChildrenInGroup(String groupId) async {
    return await _firebaseService.getChildrenInGroup(groupId);
  }

  // Legacy method names for backward compatibility
  Future<void> loadChildren() => loadItems();
  Future<void> addChild(ChildModel child) => addItem(child);
  Future<void> updateChild(ChildModel child) => updateItem(child);
  Future<void> deleteChild(String childId) => deleteItem(childId);
}

class AllChildrenController extends BaseController<ChildModel> {
  final FirebaseService _firebaseService;

  AllChildrenController(this._firebaseService) {
    loadItems();
  }

  @override
  Future<void> loadItems() async {
    setLoading();
    state = await AsyncValue.guard(() => _firebaseService.getAllChildren());
  }

  @override
  Future<void> addItem(ChildModel item) async {
    await handleOperation(() => _firebaseService.addChild(item));
  }

  @override
  Future<void> updateItem(ChildModel item) async {
    await handleOperation(() => _firebaseService.updateChild(item.id, item.toMap()));
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await handleOperation(() => _firebaseService.deleteChild(itemId));
  }

  // Legacy method names for backward compatibility
  Future<void> loadChildren() => loadItems();
  Future<void> addChild(ChildModel child) => addItem(child);
  Future<void> updateChild(ChildModel child) => updateItem(child);
  Future<void> deleteChild(String childId) => deleteItem(childId);
}
