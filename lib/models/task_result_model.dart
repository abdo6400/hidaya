import 'package:cloud_firestore/cloud_firestore.dart';

class TaskResultModel {
  final String id;
  final String childId;
  final String taskId;
  final int points;
  final String? notes;
  final String date; // YYYY-MM-DD
  final String? groupId;
  final String? categoryId;
  final String? sheikhId;
  final String? taskTitle;
  final String? taskType; // 'points' | 'yesno' | 'custom'
  final int? maxPoints;
  final DateTime? submittedAt;

  TaskResultModel({
    required this.id,
    required this.childId,
    required this.taskId,
    required this.points,
    required this.date,
    this.notes,
    this.groupId,
    this.categoryId,
    this.sheikhId,
    this.taskTitle,
    this.taskType,
    this.maxPoints,
    this.submittedAt,
  });

  factory TaskResultModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TaskResultModel(
      id: doc.id,
      childId: data['childId'] ?? '',
      taskId: data['taskId'] ?? '',
      points: (data['points'] ?? 0) as int,
      notes: data['notes'] as String?,
      date: data['date'] ?? '',
      groupId: data['groupId'] as String?,
      categoryId: data['categoryId'] as String?,
      sheikhId: data['sheikhId'] as String?,
      taskTitle: data['taskTitle'] as String?,
      taskType: data['taskType'] as String?,
      maxPoints: (data['maxPoints'] as int?),
      submittedAt: (data['submittedAt'] is Timestamp) ? (data['submittedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'taskId': taskId,
      'points': points,
      'notes': notes,
      'date': date,
      if (groupId != null) 'groupId': groupId,
      if (categoryId != null) 'categoryId': categoryId,
      if (sheikhId != null) 'sheikhId': sheikhId,
      if (taskTitle != null) 'taskTitle': taskTitle,
      if (taskType != null) 'taskType': taskType,
      if (maxPoints != null) 'maxPoints': maxPoints,
      if (submittedAt != null) 'submittedAt': Timestamp.fromDate(submittedAt!),
    };
  }
}


