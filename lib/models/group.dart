import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final String id;
  final String name;

  final String sheikhId;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Group({
    required this.id,
    required this.name,

    required this.sheikhId,

    required this.createdAt,
    required this.updatedAt,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',

      sheikhId: map['sheikhId'] ?? '',

      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,

      'sheikhId': sheikhId,

      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? sheikhId,
    String? level,
    int? maxStudents,
    String? schedule,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? studentCount,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,

      sheikhId: sheikhId ?? this.sheikhId,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, sheikhId, createdAt, updatedAt];
}
