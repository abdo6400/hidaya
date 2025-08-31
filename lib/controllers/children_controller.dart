import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_model.dart';
import '../services/firebase_service.dart';
import 'base_controller.dart';

final childrenControllerProvider =
    StateNotifierProvider<ChildrenController, AsyncValue<List<ChildModel>>>(
  (ref) => ChildrenController(FirebaseService()),
);

class ChildrenController extends BaseController<ChildModel> {
  final FirebaseService _firebaseService;

  ChildrenController(this._firebaseService) {
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

  // Additional methods for children management
  Future<List<ChildModel>> getChildrenByParent(String parentId) async {
    return await _firebaseService.getChildrenByParent(parentId);
  }

  Future<List<ChildModel>> getChildrenBySheikh(String sheikhId) async {
    return await _firebaseService.getChildrenBySheikh(sheikhId);
  }

  Future<void> approveChild(String childId) async {
    await handleOperation(() => _firebaseService.updateChild(childId, {'isApproved': true}));
  }

  Future<void> assignChildToCategory(String childId, String categoryId, String sheikhId) async {
    await handleOperation(() => _firebaseService.assignChildToCategory(childId, categoryId, sheikhId));
  }

  Future<void> unassignChild(String childId) async {
    await handleOperation(() => _firebaseService.unassignChild(childId));
  }

  // Legacy method names for backward compatibility
  Future<void> loadChildren() => loadItems();
  Future<void> addChild(ChildModel child) => addItem(child);
  Future<void> updateChild(ChildModel child) => updateItem(child);
  Future<void> deleteChild(String childId) => deleteItem(childId);
}
