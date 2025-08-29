

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupAssignmentModel {
  final String id;
  final String categoryId;
  final String sheikhId;
  final String scheduleId;
  final List<String> childrenIds;
  final DateTime createdAt;
  final bool isActive;
  final String name; // e.g. "Monday Morning Quran Group"

  GroupAssignmentModel({
    required this.id,
    required this.categoryId,
    required this.sheikhId,
    required this.scheduleId,
    required this.childrenIds,
    required this.createdAt,
    required this.name,
    this.isActive = true,
  });

  factory GroupAssignmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupAssignmentModel(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      sheikhId: data['sheikhId'] ?? '',
      scheduleId: data['scheduleId'] ?? '',
      childrenIds: List<String>.from(data['childrenIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      name: data['name'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'sheikhId': sheikhId,
      'scheduleId': scheduleId,
      'childrenIds': childrenIds,
      'createdAt': createdAt,
      'name': name,
      'isActive': isActive,
    };
  }

  GroupAssignmentModel copyWith({
    String? id,
    String? categoryId,
    String? sheikhId,
    String? scheduleId,
    List<String>? childrenIds,
    DateTime? createdAt,
    String? name,
    bool? isActive,
  }) {
    return GroupAssignmentModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      sheikhId: sheikhId ?? this.sheikhId,
      scheduleId: scheduleId ?? this.scheduleId,
      childrenIds: childrenIds ?? this.childrenIds,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}
