import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskType { points, yesNo, custom }

class TaskModel {
  final String id;
  final String title;
  final TaskType type;
  final String? categoryId;
  final int maxPoints;
  final String? customOptions; // Added field for custom task options

  TaskModel({
    required this.id,
    required this.title,
    required this.type,
    this.categoryId,
    required this.maxPoints,
    this.customOptions, // Added parameter
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      type: _parseTaskType(data['type']),
      categoryId: data['categoryId'],
      maxPoints: data['maxPoints'] ?? 10,
      customOptions: data['customOptions'], // Added field
    );
  }

  static TaskType _parseTaskType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'points':
          return TaskType.points;
        case 'yesno':
        case 'yes_no':
          return TaskType.yesNo;
        case 'custom':
          return TaskType.custom;
        default:
          return TaskType.points;
      }
    }
    return TaskType.points;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': _taskTypeToString(type),
      'categoryId': categoryId,
      'maxPoints': maxPoints,
      'customOptions': customOptions, // Added field
    };
  }

  static String _taskTypeToString(TaskType type) {
    switch (type) {
      case TaskType.points:
        return 'points';
      case TaskType.yesNo:
        return 'yesno';
      case TaskType.custom:
        return 'custom';
    }
  }
}
