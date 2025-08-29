import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import '../services/schedules_service.dart';

final schedulesControllerProvider =
    StateNotifierProvider.family<
      SchedulesController,
      AsyncValue<List<ScheduleModel>>,
      String
    >((ref, type) => SchedulesController(SchedulesService(), type));

class SchedulesController
    extends StateNotifier<AsyncValue<List<ScheduleModel>>> {
  final SchedulesService _schedulesService;
  final String type; // 'all' or sheikhId

  SchedulesController(this._schedulesService, this.type)
    : super(const AsyncValue.loading()) {
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    state = const AsyncValue.loading();
    try {
      final schedules = type == 'all'
          ? await _schedulesService.getAllSchedules()
          : await _schedulesService.getSchedulesBySheikh(type);
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    try {
      final id = await _schedulesService.addSchedule(schedule);
      final newSchedule = schedule.copyWith(id: id);
      state.whenData((schedules) {
        state = AsyncValue.data([...schedules, newSchedule]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    try {
      await _schedulesService.updateSchedule(schedule.id, schedule);
      state.whenData((schedules) {
        state = AsyncValue.data(
          schedules.map((s) => s.id == schedule.id ? schedule : s).toList(),
        );
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      await _schedulesService.deleteSchedule(id);
      state.whenData((schedules) {
        state = AsyncValue.data(
          schedules
              .map((s) => s.id == id ? s.copyWith(isActive: false) : s)
              .toList(),
        );
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> checkScheduleConflict(
    String sheikhId,
    WeekDay day,
    String startTime,
    String endTime, {
    String? excludeScheduleId,
  }) async {
    try {
      return await _schedulesService.hasScheduleConflict(
        sheikhId,
        day,
        startTime,
        endTime,
        excludeScheduleId: excludeScheduleId,
      );
    } catch (e) {
      return false;
    }
  }
}
