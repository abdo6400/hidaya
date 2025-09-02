import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_group_model.dart';
import '../models/schedule_model.dart';
import '../services/firebase_service.dart';
import 'base_controller.dart';

final scheduleGroupsControllerProvider =
    StateNotifierProvider<ScheduleGroupsController, AsyncValue<List<ScheduleGroupModel>>>(
  (ref) => ScheduleGroupsController(FirebaseService()),
);

class ScheduleGroupsController extends BaseController<ScheduleGroupModel> {
  final FirebaseService _firebaseService;

  ScheduleGroupsController(this._firebaseService) {
    loadItems();
  }

  @override
  Future<void> loadItems() async {
    setLoading();
    state = await AsyncValue.guard(() => _firebaseService.getAllScheduleGroups());
  }

  @override
  Future<void> addItem(ScheduleGroupModel item) async {
    await handleOperation(() => _firebaseService.addScheduleGroup(item));
  }

  @override
  Future<void> updateItem(ScheduleGroupModel item) async {
    await handleOperation(() => _firebaseService.updateScheduleGroup(item));
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await handleOperation(() => _firebaseService.deleteScheduleGroup(itemId));
  }

  // Additional methods for schedule group management
  Future<List<ScheduleGroupModel>> getScheduleGroupsBySheikh(String sheikhId) async {
    return await _firebaseService.getScheduleGroupsBySheikh(sheikhId);
  }

  Future<ScheduleGroupModel?> getScheduleGroupById(String groupId) async {
    return await _firebaseService.getScheduleGroupById(groupId);
  }

  // Legacy method names for backward compatibility
  Future<void> loadScheduleGroups() => loadItems();
  Future<void> addScheduleGroup(ScheduleGroupModel group) => addItem(group);
  Future<void> updateScheduleGroup(ScheduleGroupModel group) => updateItem(group);
  Future<void> deleteScheduleGroup(String groupId) => deleteItem(groupId);

  // Check for schedule conflicts
  Future<bool> hasScheduleConflict(
    List<WeekDay> days, 
    List<TimeSlot> timeSlots, 
    {String? excludeGroupId}
  ) async {
    // // This is a simplified conflict check - you can implement more sophisticated logic
    // final existingGroups = await _firebaseService.getAllScheduleGroups();
    
    // for (final group in existingGroups) {
    //   // Skip the group being edited
    //   if (excludeGroupId != null && group.id == excludeGroupId) {
    //     continue;
    //   }
      
    //   for (final day in group.days) {
    //     if (days.contains(day.day)) {
    //       // Check if time slots overlap
    //       for (final existingSlot in day.timeSlots) {
    //         for (final newSlot in timeSlots) {
    //           if (_doTimeSlotsOverlap(existingSlot, newSlot)) {
    //             return true; // Conflict found
    //           }
    //         }
    //       }
    //     }
    //   }
    // }
    return false; // No conflicts
  }

  bool _doTimeSlotsOverlap(TimeSlot slot1, TimeSlot slot2) {
    // Simple time overlap check - you can implement more sophisticated logic
    return slot1.startTime == slot2.startTime || slot1.endTime == slot2.endTime;
  }
}
