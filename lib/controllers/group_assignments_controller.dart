import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group_assignment_model.dart';
import '../services/group_assignment_service.dart';

final groupAssignmentsProvider =
    StateNotifierProvider<GroupAssignmentsController, AsyncValue<List<GroupAssignmentModel>>>(
  (ref) => GroupAssignmentsController(GroupAssignmentService()),
);

class GroupAssignmentsController
    extends StateNotifier<AsyncValue<List<GroupAssignmentModel>>> {
  final GroupAssignmentService _service;

  GroupAssignmentsController(this._service) : super(const AsyncValue.loading()) {
    loadGroups();
  }

  Future<void> loadGroups() async {
    try {
      state = const AsyncValue.loading();
      final groups = await _service.getActiveGroups();
      state = AsyncValue.data(groups);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createGroup({
    required String categoryId,
    required String sheikhId,
    required String scheduleId,
    required List<String> childrenIds,
    required String name,
  }) async {
    try {
      final group = GroupAssignmentModel(
        id: '',
        categoryId: categoryId,
        sheikhId: sheikhId,
        scheduleId: scheduleId,
        childrenIds: childrenIds,
        createdAt: DateTime.now(),
        name: name,
      );

      await _service.createGroupAssignment(group);
      await loadGroups();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateGroup(GroupAssignmentModel group) async {
    try {
      await _service.updateGroup(group.id, group);
      await loadGroups();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await _service.deleteGroup(groupId);
      await loadGroups();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addChildrenToGroup(
      String groupId, List<String> childrenIds) async {
    try {
      await _service.addChildrenToGroup(groupId, childrenIds);
      await loadGroups();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeChildrenFromGroup(
      String groupId, List<String> childrenIds) async {
    try {
      await _service.removeChildrenFromGroup(groupId, childrenIds);
      await loadGroups();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
