import 'package:cloud_firestore/cloud_firestore.dart';
import 'schedule_model.dart';

class ScheduleGroupModel {
  final String id;
  final String sheikhId;
  final String name;
  final String description;
  final List<DaySchedule> days;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ScheduleGroupModel({
    required this.id,
    required this.sheikhId,
    required this.name,
    required this.description,
    required this.days,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory ScheduleGroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScheduleGroupModel(
      id: doc.id,
      sheikhId: data['sheikhId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      days:
          (data['days'] as List?)
              ?.map((day) => DaySchedule.fromMap(day as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sheikhId': sheikhId,
      'name': name,
      'description': description,
      'days': days.map((day) => day.toMap()).toList(),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  ScheduleGroupModel copyWith({
    String? id,
    String? sheikhId,
    String? name,
    String? description,
    List<DaySchedule>? days,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleGroupModel(
      id: id ?? this.id,
      sheikhId: sheikhId ?? this.sheikhId,
      name: name ?? this.name,
      description: description ?? this.description,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  List<WeekDay> get weekDays => days.map((day) => day.day).toList();

  String get daysDisplay {
    if (days.isEmpty) return 'لا توجد أيام';
    return days.map((day) => _getDayName(day.day)).join('، ');
  }

  String _getDayName(WeekDay day) {
    switch (day) {
      case WeekDay.sunday:
        return 'الأحد';
      case WeekDay.monday:
        return 'الاثنين';
      case WeekDay.tuesday:
        return 'الثلاثاء';
      case WeekDay.wednesday:
        return 'الأربعاء';
      case WeekDay.thursday:
        return 'الخميس';
      case WeekDay.friday:
        return 'الجمعة';
      case WeekDay.saturday:
        return 'السبت';
    }
  }
}
