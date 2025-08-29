import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assignment_model.dart';
import '../services/children_service.dart';

final assignmentsControllerProvider = StateNotifierProvider<AssignmentsController,
    AsyncValue<List<AssignmentModel>>>((ref) {
  return AssignmentsController(ChildrenService());
});

class AssignmentsController extends StateNotifier<AsyncValue<List<AssignmentModel>>> {
  final ChildrenService _childrenService;

  AssignmentsController(this._childrenService)
      : super(const AsyncValue.loading());

  Future<void> assignChild({
    required String childId,
    required String categoryId,
    required String sheikhId,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _childrenService.assignChildToCategory(
        childId,
        categoryId,
        sheikhId,
      );
      // Optionally reload assignments here if needed
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unassignChild(String childId) async {
    try {
      state = const AsyncValue.loading();
      await _childrenService.unassignChildFromCategory(childId);
      // Optionally reload assignments here if needed
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AssignmentModel?> getActiveAssignment(String childId) async {
    try {
      return await _childrenService.getActiveAssignment(childId);
    } catch (e) {
      return null;
    }
  }
}
