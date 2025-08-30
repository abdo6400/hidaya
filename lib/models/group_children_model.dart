import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChildrenModel {
  final String id;
  final String groupId;
  final String childId;
  final DateTime assignedAt;
  final bool isActive;
  final String? notes;

  GroupChildrenModel({
    required this.id,
    required this.groupId,
    required this.childId,
    required this.assignedAt,
    this.isActive = true,
    this.notes,
  });

  factory GroupChildrenModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupChildrenModel(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      childId: data['childId'] ?? '',
      assignedAt: (data['assignedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'childId': childId,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'isActive': isActive,
      'notes': notes,
    };
  }

  GroupChildrenModel copyWith({
    String? id,
    String? groupId,
    String? childId,
    DateTime? assignedAt,
    bool? isActive,
    String? notes,
  }) {
    return GroupChildrenModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      childId: childId ?? this.childId,
      assignedAt: assignedAt ?? this.assignedAt,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }
}
