import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Sheikh extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? groupId;

  const Sheikh({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.groupId,
  });

  factory Sheikh.fromMap(Map<String, dynamic> map) {
    return Sheikh(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      groupId: map['groupId'] ?? '',

      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,

      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'groupId': groupId,
    };
  }

  Sheikh copyWith({
    String? id,
    String? name,

    DateTime? createdAt,
    DateTime? updatedAt,
    String? groupId,
  }) {
    return Sheikh(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt, groupId];
}
