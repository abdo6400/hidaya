import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/group_children_model.dart';
import 'package:hidaya/services/group_children_service.dart';

// Service provider
final groupChildrenServiceProvider = Provider<GroupChildrenService>((ref) {
  return GroupChildrenService();
});

// Controller for managing group children assignments
class GroupChildrenController
    extends StateNotifier<AsyncValue<List<ChildModel>>> {
  final GroupChildrenService _service;

  GroupChildrenController(this._service) : super(const AsyncValue.loading());

  // Get children in a specific group
  Future<void> getChildrenInGroup(String groupId) async {
    state = const AsyncValue.loading();
    try {
      final children = await _service.getChildrenInGroup(groupId);
      state = AsyncValue.data(children);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Assign a child to a group
  Future<void> assignChildToGroup({
    required String childId,
    required String groupId,
    String? notes,
  }) async {
    try {
      await _service.assignChildToGroup(groupId, childId, notes: notes);

      // Refresh the children list for this group
      await getChildrenInGroup(groupId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Remove a child from a group
  Future<void> removeChildFromGroup(String groupId, String childId) async {
    try {
      await _service.removeChildFromGroup(groupId, childId);

      // Refresh the current state
      if (state.hasValue) {
        final currentChildren = state.value!;
        final updatedChildren = currentChildren
            .where((child) => child.id != childId)
            .toList();
        state = AsyncValue.data(updatedChildren);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Get groups for a specific child
  Future<List<String>> getGroupsForChild(String childId) async {
    try {
      return await _service.getGroupsForChild(childId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Update assignment notes
  Future<void> updateAssignmentNotes(String assignmentId, String notes) async {
    try {
      await _service.updateGroupAssignmentNotes(assignmentId, notes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Check if a child is in a group
  Future<bool> isChildInGroup(String childId, String groupId) async {
    try {
      return await _service.isChildInGroup(childId, groupId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Get children count in a group
  Future<int> getChildrenCountInGroup(String groupId) async {
    try {
      return await _service.getChildrenCountInGroup(groupId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

// Provider for the controller
final groupChildrenControllerProvider =
    StateNotifierProvider<
      GroupChildrenController,
      AsyncValue<List<ChildModel>>
    >((ref) {
      final service = ref.watch(groupChildrenServiceProvider);
      return GroupChildrenController(service);
    });

// Provider for children in a specific group
final groupChildrenProvider = FutureProvider.family<List<ChildModel>, String>((
  ref,
  groupId,
) async {
  final service = ref.watch(groupChildrenServiceProvider);
  return await service.getChildrenInGroup(groupId);
});

// Provider for groups assigned to a child
final childGroupsProvider = FutureProvider.family<List<String>, String>((
  ref,
  childId,
) async {
  final service = ref.watch(groupChildrenServiceProvider);
  return await service.getGroupsForChild(childId);
});

// Provider for children count in a group
final groupChildrenCountProvider = FutureProvider.family<int, String>((
  ref,
  groupId,
) async {
  final service = ref.watch(groupChildrenServiceProvider);
  return await service.getChildrenCountInGroup(groupId);
});
