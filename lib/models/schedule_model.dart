// models/schedule_model.dart
class ScheduleModel {
  final String id;
  final String sheikhId;
  final String day; // e.g. "Monday"
  final String startTime; // "09:00"
  final String endTime; // "11:00"
  final String categoryId;
  final String notes;

  ScheduleModel({
    required this.id,
    required this.sheikhId,
    required this.day,
    required this.startTime,
    required this.categoryId,
    required this.endTime,
    required this.notes,
  });

  factory ScheduleModel.fromMap(String id, Map<String, dynamic> map) {
    return ScheduleModel(
      id: id,
      sheikhId: map['sheikhId'] ?? '',
      day: map['day'] ?? '',
      startTime: map['startTime'] ?? '',
      categoryId: map['categoryId'] ?? '',
      endTime: map['endTime'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sheikhId': sheikhId,
      'day': day,
      'startTime': startTime,
      'categoryId': categoryId,
      'endTime': endTime,
      'notes': notes,
    };
  }
}
