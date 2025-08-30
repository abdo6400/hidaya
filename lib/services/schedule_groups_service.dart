import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_group_model.dart';
import '../models/schedule_model.dart';

class ScheduleGroupsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _scheduleGroups =>
      _firestore.collection('schedule_groups');

  // Get all schedule groups
  Future<List<ScheduleGroupModel>> getAllScheduleGroups() async {
    final snapshot = await _scheduleGroups
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => ScheduleGroupModel.fromFirestore(doc))
        .toList();
  }

  // Get schedule groups by sheikh
  Future<List<ScheduleGroupModel>> getScheduleGroupsBySheikh(
    String sheikhId,
  ) async {
    final snapshot = await _scheduleGroups
        .where('sheikhId', isEqualTo: sheikhId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ScheduleGroupModel.fromFirestore(doc))
        .toList();
  }

  // Add schedule group
  Future<String> addScheduleGroup(ScheduleGroupModel group) async {
    final doc = await _scheduleGroups.add(group.toMap());
    return doc.id;
  }

  // Update schedule group
  Future<void> updateScheduleGroup(String id, ScheduleGroupModel group) async {
    final updatedData = group.copyWith(updatedAt: DateTime.now()).toMap();
    await _scheduleGroups.doc(id).update(updatedData);
  }

  // Delete schedule group (soft delete)
  Future<void> deleteScheduleGroup(String id) async {
    await _scheduleGroups.doc(id).update({
      'isActive': false,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Hard delete schedule group
  Future<void> hardDeleteScheduleGroup(String id) async {
    await _scheduleGroups.doc(id).delete();
  }

  // Get schedule group by ID
  Future<ScheduleGroupModel?> getScheduleGroupById(String id) async {
    final doc = await _scheduleGroups.doc(id).get();
    if (!doc.exists) return null;
    return ScheduleGroupModel.fromFirestore(doc);
  }

  // Check for schedule conflicts
  Future<bool> hasScheduleConflict(
    String sheikhId,
    List<WeekDay> days,
    List<TimeSlot> timeSlots, {
    String? excludeGroupId,
  }) async {
    final groups = await getScheduleGroupsBySheikh(sheikhId);

    for (var group in groups) {
      if (excludeGroupId != null && group.id == excludeGroupId) {
        continue;
      }

      // Check if any days overlap
      final overlappingDays = group.weekDays
          .where((day) => days.contains(day))
          .toList();
      if (overlappingDays.isEmpty) continue;

      // Check time conflicts for overlapping days
      for (var day in overlappingDays) {
        final groupDaySchedule = group.days.firstWhere(
          (d) => d.day == day,
          orElse: () => DaySchedule(day: day, timeSlots: []),
        );

        for (var newSlot in timeSlots) {
          for (var existingSlot in groupDaySchedule.timeSlots) {
            if (_hasTimeConflict(
              newSlot.startTime,
              newSlot.endTime,
              existingSlot.startTime,
              existingSlot.endTime,
            )) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  bool _hasTimeConflict(
    String start1,
    String end1,
    String start2,
    String end2,
  ) {
    // Convert times to comparable format (assuming HH:mm format)
    final start1Minutes = _timeToMinutes(start1);
    final end1Minutes = _timeToMinutes(end1);
    final start2Minutes = _timeToMinutes(start2);
    final end2Minutes = _timeToMinutes(end2);

    return start1Minutes < end2Minutes && end1Minutes > start2Minutes;
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Get groups with children count
  Future<List<Map<String, dynamic>>> getGroupsWithChildrenCount(
    String sheikhId,
  ) async {
    final groups = await getScheduleGroupsBySheikh(sheikhId);
    final result = <Map<String, dynamic>>[];

    for (var group in groups) {
      final childrenCount = await _getChildrenCountForGroup(group.id);
      result.add({'group': group, 'childrenCount': childrenCount});
    }

    return result;
  }

  Future<int> _getChildrenCountForGroup(String groupId) async {
    final snapshot = await _firestore
        .collection('group_children')
        .where('groupId', isEqualTo: groupId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }
}
