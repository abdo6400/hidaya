import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_group_model.dart';
import '../models/schedule_model.dart';
import '../services/schedule_groups_service.dart';

final scheduleGroupsServiceProvider = Provider(
  (ref) => ScheduleGroupsService(),
);

final scheduleGroupsControllerProvider =
    StateNotifierProvider.family<
      ScheduleGroupsController,
      AsyncValue<List<ScheduleGroupModel>>,
      String
    >(
      (ref, sheikhId) => ScheduleGroupsController(
        ref.read(scheduleGroupsServiceProvider),
        sheikhId,
      ),
    );

final scheduleGroupsWithCountControllerProvider =
    StateNotifierProvider.family<
      ScheduleGroupsWithCountController,
      AsyncValue<List<Map<String, dynamic>>>,
      String
    >(
      (ref, sheikhId) => ScheduleGroupsWithCountController(
        ref.read(scheduleGroupsServiceProvider),
        sheikhId,
      ),
    );

class ScheduleGroupsController
    extends StateNotifier<AsyncValue<List<ScheduleGroupModel>>> {
  final ScheduleGroupsService _service;
  final String _sheikhId;

  ScheduleGroupsController(this._service, this._sheikhId)
    : super(const AsyncValue.loading()) {
    loadScheduleGroups();
  }

  Future<void> loadScheduleGroups() async {
    state = const AsyncValue.loading();
    try {
      final groups = await _service.getScheduleGroupsBySheikh(_sheikhId);
      state = AsyncValue.data(groups);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addScheduleGroup(ScheduleGroupModel group) async {
    try {
      await _service.addScheduleGroup(group);
      await loadScheduleGroups();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateScheduleGroup(String id, ScheduleGroupModel group) async {
    try {
      await _service.updateScheduleGroup(id, group);
      await loadScheduleGroups();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteScheduleGroup(String id) async {
    try {
      await _service.deleteScheduleGroup(id);
      await loadScheduleGroups();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> hasScheduleConflict(
    List<WeekDay> days,
    List<TimeSlot> timeSlots, {
    String? excludeGroupId,
  }) async {
    try {
      return await _service.hasScheduleConflict(
        _sheikhId,
        days,
        timeSlots,
        excludeGroupId: excludeGroupId,
      );
    } catch (error) {
      return false;
    }
  }
}

class ScheduleGroupsWithCountController
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ScheduleGroupsService _service;
  final String _sheikhId;

  ScheduleGroupsWithCountController(this._service, this._sheikhId)
    : super(const AsyncValue.loading()) {
    loadScheduleGroupsWithCount();
  }

  Future<void> loadScheduleGroupsWithCount() async {
    state = const AsyncValue.loading();
    try {
      final groupsWithCount = await _service.getGroupsWithChildrenCount(
        _sheikhId,
      );
      state = AsyncValue.data(groupsWithCount);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadScheduleGroupsWithCount();
  }
}
