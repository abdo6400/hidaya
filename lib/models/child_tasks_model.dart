import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { pending, completed, inProgress }

class ChildTasksModel {
  final String id;
  final String childId;
  final String taskId;
  final String groupId;
  final TaskStatus status;
  final double? mark;
  final DateTime assignedAt;
  final DateTime? completedAt;
  final String? notes;
  final String assignedBy; // sheikh ID

  ChildTasksModel({
    required this.id,
    required this.childId,
    required this.taskId,
    required this.groupId,
    this.status = TaskStatus.pending,
    this.mark,
    required this.assignedAt,
    this.completedAt,
    this.notes,
    required this.assignedBy,
  });

  factory ChildTasksModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChildTasksModel(
      id: doc.id,
      childId: data['childId'] ?? '',
      taskId: data['taskId'] ?? '',
      groupId: data['groupId'] ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${data['status']}',
        orElse: () => TaskStatus.pending,
      ),
      mark: data['mark']?.toDouble(),
      assignedAt: (data['assignedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
      assignedBy: data['assignedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'taskId': taskId,
      'groupId': groupId,
      'status': status.toString().split('.').last,
      'mark': mark,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'notes': notes,
      'assignedBy': assignedBy,
    };
  }

  ChildTasksModel copyWith({
    String? id,
    String? childId,
    String? taskId,
    String? groupId,
    TaskStatus? status,
    double? mark,
    DateTime? assignedAt,
    DateTime? completedAt,
    String? notes,
    String? assignedBy,
  }) {
    return ChildTasksModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      taskId: taskId ?? this.taskId,
      groupId: groupId ?? this.groupId,
      status: status ?? this.status,
      mark: mark ?? this.mark,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      assignedBy: assignedBy ?? this.assignedBy,
    );
  }

  // Helper methods
  bool get isCompleted => status == TaskStatus.completed;
  bool get isPending => status == TaskStatus.pending;
  bool get isInProgress => status == TaskStatus.inProgress;

  String get statusDisplay {
    switch (status) {
      case TaskStatus.pending:
        return 'في الانتظار';
      case TaskStatus.inProgress:
        return 'قيد التنفيذ';
      case TaskStatus.completed:
        return 'مكتمل';
    }
  }
}
