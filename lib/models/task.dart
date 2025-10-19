import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TaskType { graded, attendance }

class Task extends Equatable {
  final String id;
  final String name;
  final TaskType type;
  final double? maxScore; // Only for graded tasks
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.name,
    required this.type,
    this.maxScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      name: map['name'] ?? '',

      type: TaskType.values.firstWhere(
        (e) => e.toString() == 'TaskType.${map['type']}',
        orElse: () => TaskType.graded,
      ),
      maxScore: map['maxScore']?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
 
      'type': type.toString().split('.').last,
      'maxScore': maxScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Task copyWith({
    String? id,
    String? name,
    TaskType? type,
    double? maxScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      maxScore: maxScore ?? this.maxScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        maxScore,
        createdAt,
        updatedAt,
      ];
}
