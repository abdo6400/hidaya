import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class SchedulesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _schedules =>
      _firestore.collection('schedules');

  // Get all schedules
  Future<List<ScheduleModel>> getAllSchedules() async {
    final snapshot = await _schedules.get();
    return snapshot.docs
        .map((doc) => ScheduleModel.fromFirestore(doc))
        .toList();
  }

  // Get schedules by sheikh
  Future<List<ScheduleModel>> getSchedulesBySheikh(String sheikhId) async {
    final snapshot = await _schedules
        .where('sheikhId', isEqualTo: sheikhId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => ScheduleModel.fromFirestore(doc))
        .toList();
  }

  // Add schedule
  Future<String> addSchedule(ScheduleModel schedule) async {
    final doc = await _schedules.add(schedule.toMap());
    return doc.id;
  }

  // Update schedule
  Future<void> updateSchedule(String id, ScheduleModel schedule) async {
    await _schedules.doc(id).update(schedule.toMap());
  }

  // Delete schedule (soft delete)
  Future<void> deleteSchedule(String id) async {
    await _schedules.doc(id).update({'isActive': false});
  }

  // Hard delete schedule
  Future<void> hardDeleteSchedule(String id) async {
    await _schedules.doc(id).delete();
  }

  // Get schedule by ID
  Future<ScheduleModel?> getScheduleById(String id) async {
    final doc = await _schedules.doc(id).get();
    if (!doc.exists) return null;
    return ScheduleModel.fromFirestore(doc);
  }
  
  // Check for schedule conflicts
  Future<bool> hasScheduleConflict(String sheikhId, WeekDay day, String startTime, String endTime, {String? excludeScheduleId}) async {
    final schedules = await getSchedulesBySheikh(sheikhId);
    
    for (var schedule in schedules) {
      if (excludeScheduleId != null && schedule.id == excludeScheduleId) {
        continue;
      }
      
      final daySchedule = schedule.days.firstWhere(
        (d) => d.day == day,
        orElse: () => DaySchedule(day: day, timeSlots: []),
      );
      
      for (var slot in daySchedule.timeSlots) {
        if (_hasTimeConflict(startTime, endTime, slot.startTime, slot.endTime)) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  bool _hasTimeConflict(String start1, String end1, String start2, String end2) {
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
}
