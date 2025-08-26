import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_model.dart';
import '../services/parents_service.dart';

final childrenControllerProvider =
    StateNotifierProvider.family<ChildrenController, AsyncValue<List<ChildModel>>, String>(
  (ref, parentId) => ChildrenController(ParentsService(), parentId),
);

class ChildrenController extends StateNotifier<AsyncValue<List<ChildModel>>> {
  final ParentsService _parentsService;
  final String parentId;

  ChildrenController(this._parentsService, this.parentId) : super(const AsyncValue.loading()) {
    loadChildren();
  }

  Future<void> loadChildren() async {
    try {
      state = const AsyncValue.loading();
      final children = await _parentsService.getChildrenByParent(parentId);
      state = AsyncValue.data(children);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addChild(String name, String age, {bool byAdmin = true}) async {
    try {
      await _parentsService.addChild(
        name: name,
        age: age,
        parentId: parentId,
        createdBy: byAdmin ? "admin" : "parent",
      );
      await loadChildren();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> approveChild(String childId) async {
    try {
      await _parentsService.approveChild(childId);
      await loadChildren();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteChild(String childId) async {
    try {
      await _parentsService.deleteChild(childId);
      await loadChildren();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
