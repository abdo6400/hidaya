import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String name;
  final String sheikhId;
  final String sheikhName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalGradedScore;
  final int attendanceCount;

  const Student({
    required this.id,
    required this.name,
    required this.sheikhId,
    required this.sheikhName,
    required this.createdAt,
    required this.updatedAt,
    this.totalGradedScore = 0.0,
    this.attendanceCount = 0,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      sheikhId: map['sheikhId'] ?? '',
      sheikhName: map['sheikhName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      totalGradedScore: (map['totalGradedScore'] ?? 0.0).toDouble(),
      attendanceCount: map['attendanceCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sheikhId': sheikhId,

      'sheikhName': sheikhName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'totalGradedScore': totalGradedScore,
      'attendanceCount': attendanceCount,
    };
  }

  Student copyWith({
    String? id,
    String? name,
    String? sheikhId,
    String? groupId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalGradedScore,
    int? attendanceCount,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      sheikhId: sheikhId ?? this.sheikhId,

      sheikhName: sheikhName ?? this.sheikhName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalGradedScore: totalGradedScore ?? this.totalGradedScore,
      attendanceCount: attendanceCount ?? this.attendanceCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    sheikhId,

    sheikhName,
    createdAt,
    updatedAt,
    totalGradedScore,
    attendanceCount,
  ];
}
