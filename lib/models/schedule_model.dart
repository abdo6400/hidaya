import 'package:cloud_firestore/cloud_firestore.dart';

enum WeekDay {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final String categoryId;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'categoryId': categoryId,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      categoryId: map['categoryId'] ?? '',
    );
  }
}

class DaySchedule {
  final WeekDay day;
  final List<TimeSlot> timeSlots;

  DaySchedule({
    required this.day,
    required this.timeSlots,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day.name,
      'timeSlots': timeSlots.map((slot) => slot.toMap()).toList(),
    };
  }

  factory DaySchedule.fromMap(Map<String, dynamic> map) {
    return DaySchedule(
      day: WeekDay.values.firstWhere(
        (d) => d.name == map['day'],
        orElse: () => WeekDay.sunday,
      ),
      timeSlots: (map['timeSlots'] as List?)
              ?.map((slot) => TimeSlot.fromMap(slot as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ScheduleModel {
  final String id;
  final String sheikhId;
  final List<DaySchedule> days;
  final String notes;
  final bool isActive;

  ScheduleModel({
    required this.id,
    required this.sheikhId,
    required this.days,
    this.notes = '',
    this.isActive = true,
  });

  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScheduleModel(
      id: doc.id,
      sheikhId: data['sheikhId'] ?? '',
      days: (data['days'] as List?)
              ?.map((day) => DaySchedule.fromMap(day as Map<String, dynamic>))
              .toList() ??
          [],
      notes: data['notes'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sheikhId': sheikhId,
      'days': days.map((day) => day.toMap()).toList(),
      'notes': notes,
      'isActive': isActive,
    };
  }

  ScheduleModel copyWith({
    String? id,
    String? sheikhId,
    List<DaySchedule>? days,
    String? notes,
    bool? isActive,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      sheikhId: sheikhId ?? this.sheikhId,
      days: days ?? this.days,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
  }

