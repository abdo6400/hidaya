import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Result extends Equatable {
  final String id;
  final String studentId;
  final String taskId;
  final String title;
  final double? score; // For graded tasks
  final bool? attendance; // For attendance tasks
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Result({
    required this.id,
    required this.studentId,
    required this.taskId,
    required this.title,
    this.score,
    this.attendance,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      taskId: map['taskId'] ?? '',
      title: map['title'] ?? '',
      score: map['score']?.toDouble(),
      attendance: map['attendance'],
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'taskId': taskId,
      'title': title,
      'score': score,
      'attendance': attendance,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Result copyWith({
    String? id,
    String? studentId,
    String? taskId,
    String? title,
    double? score,
    bool? attendance,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Result(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      score: score ?? this.score,
      attendance: attendance ?? this.attendance,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        taskId,
        title,
        score,
        attendance,
        date,
        createdAt,
        updatedAt,
      ];
}
