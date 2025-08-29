import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/child_model.dart';
import '../services/children_service.dart';

final assignChildrenControllerProvider =
    StateNotifierProvider<AssignChildrenController, AsyncValue<List<ChildModel>>>(
  (ref) => AssignChildrenController(ChildrenService()),
);

class AssignChildrenController
    extends StateNotifier<AsyncValue<List<ChildModel>>> {
  final ChildrenService _childrenService;

  AssignChildrenController(this._childrenService)
    : super(const AsyncValue.loading()) {
    loadChildren();
  }

  Future<void> loadChildren() async {
    try {
      state = const AsyncValue.loading();
      final children = await _childrenService.getAllChildren();
      state = AsyncValue.data(children);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> assignChildToCategory(
    String childId,
    String categoryId,
    String sheikhId,
  ) async {
    try {
      await _childrenService.assignChildToCategory(
        childId,
        categoryId,
        sheikhId,
      );
      await loadChildren();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unassignChildFromCategory(String childId) async {
    try {
      await _childrenService.unassignChildFromCategory(childId);
      await loadChildren();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }



  Future<void> refresh() async {
    await loadChildren();
  }
}
