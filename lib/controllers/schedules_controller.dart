// controllers/schedules_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import '../services/sheiks_service.dart';


final schedulesControllerProvider = StateNotifierProvider.family<
    SchedulesController, AsyncValue<List<ScheduleModel>>, String>(
  (ref, sheikhId) => SchedulesController(SheiksService(), sheikhId),
);

class SchedulesController extends StateNotifier<AsyncValue<List<ScheduleModel>>> {
  final SheiksService _schedulesService;
  final String sheikhId;

  SchedulesController(this._schedulesService, this.sheikhId)
      : super(const AsyncValue.loading()) {
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    state = const AsyncValue.loading();
    try {
      final schedules = await _schedulesService.getSchedules(sheikhId);
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    try {
      final newSchedule = await _schedulesService.addSchedule(schedule);
      if (newSchedule != null) {
        state.whenData((list) => state = AsyncValue.data([...list, newSchedule]));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSchedule(String scheduleId, Map<String, dynamic> data) async {
    try {
      await _schedulesService.updateSchedule(scheduleId, data);
      await loadSchedules();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _schedulesService.deleteSchedule(scheduleId);
      state.whenData(
        (list) => state = AsyncValue.data(list.where((s) => s.id != scheduleId).toList()),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
