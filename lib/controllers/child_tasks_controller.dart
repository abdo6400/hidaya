import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_tasks_model.dart';
import '../services/child_tasks_service.dart';

final childTasksServiceProvider = Provider((ref) => ChildTasksService());

final childTasksControllerProvider =
    StateNotifierProvider.family<
      ChildTasksController,
      AsyncValue<List<ChildTasksModel>>,
      String
    >(
      (ref, childId) =>
          ChildTasksController(ref.read(childTasksServiceProvider), childId),
    );

final groupTasksControllerProvider =
    StateNotifierProvider.family<
      GroupTasksController,
      AsyncValue<List<ChildTasksModel>>,
      String
    >(
      (ref, groupId) =>
          GroupTasksController(ref.read(childTasksServiceProvider), groupId),
    );

final childProgressControllerProvider =
    StateNotifierProvider.family<
      ChildProgressController,
      AsyncValue<Map<String, dynamic>>,
      String
    >(
      (ref, childId) =>
          ChildProgressController(ref.read(childTasksServiceProvider), childId),
    );

final groupProgressControllerProvider =
    StateNotifierProvider.family<
      GroupProgressController,
      AsyncValue<Map<String, dynamic>>,
      String
    >(
      (ref, groupId) =>
          GroupProgressController(ref.read(childTasksServiceProvider), groupId),
    );

final childRankingControllerProvider =
    StateNotifierProvider.family<
      ChildRankingController,
      AsyncValue<List<Map<String, dynamic>>>,
      String
    >(
      (ref, groupId) =>
          ChildRankingController(ref.read(childTasksServiceProvider), groupId),
    );

class ChildTasksController
    extends StateNotifier<AsyncValue<List<ChildTasksModel>>> {
  final ChildTasksService _service;
  final String _childId;

  ChildTasksController(this._service, this._childId)
    : super(const AsyncValue.loading()) {
    loadChildTasks();
  }

  Future<void> loadChildTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _service.getTasksForChild(_childId);
      state = AsyncValue.data(tasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> assignTask(
    String taskId,
    String groupId,
    String assignedBy, {
    String? notes,
  }) async {
    try {
      await _service.assignTaskToChild(
        _childId,
        taskId,
        groupId,
        assignedBy,
        notes: notes,
      );
      await loadChildTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTaskStatus(
    String taskId,
    TaskStatus status, {
    double? mark,
    String? notes,
  }) async {
    try {
      await _service.updateTaskStatus(taskId, status, mark: mark, notes: notes);
      await loadChildTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _service.deleteChildTask(taskId);
      await loadChildTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class GroupTasksController
    extends StateNotifier<AsyncValue<List<ChildTasksModel>>> {
  final ChildTasksService _service;
  final String _groupId;

  GroupTasksController(this._service, this._groupId)
    : super(const AsyncValue.loading()) {
    loadGroupTasks();
  }

  Future<void> loadGroupTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _service.getTasksForGroup(_groupId);
      state = AsyncValue.data(tasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> bulkAssignTasks(
    List<String> taskIds,
    List<String> childIds,
    String assignedBy,
  ) async {
    try {
      await _service.bulkAssignTasksToGroup(
        _groupId,
        taskIds,
        childIds,
        assignedBy,
      );
      await loadGroupTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ChildProgressController
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ChildTasksService _service;
  final String _childId;

  ChildProgressController(this._service, this._childId)
    : super(const AsyncValue.loading()) {
    loadChildProgress();
  }

  Future<void> loadChildProgress() async {
    state = const AsyncValue.loading();
    try {
      final progress = await _service.getChildProgress(_childId);
      state = AsyncValue.data(progress);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadChildProgress();
  }
}

class GroupProgressController
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ChildTasksService _service;
  final String _groupId;

  GroupProgressController(this._service, this._groupId)
    : super(const AsyncValue.loading()) {
    loadGroupProgress();
  }

  Future<void> loadGroupProgress() async {
    state = const AsyncValue.loading();
    try {
      final progress = await _service.getGroupProgress(_groupId);
      state = AsyncValue.data(progress);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadGroupProgress();
  }
}

class ChildRankingController
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ChildTasksService _service;
  final String _groupId;

  ChildRankingController(this._service, this._groupId)
    : super(const AsyncValue.loading()) {
    loadChildRanking();
  }

  Future<void> loadChildRanking() async {
    state = const AsyncValue.loading();
    try {
      final ranking = await _service.getChildRankingInGroup(_groupId);
      state = AsyncValue.data(ranking);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadChildRanking();
  }
}
