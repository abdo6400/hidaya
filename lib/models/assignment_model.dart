import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String id;
  final String childId;
  final String categoryId;
  final String sheikhId;
  final DateTime assignedAt;
  final bool isActive;

  AssignmentModel({
    required this.id,
    required this.childId,
    required this.categoryId,
    required this.sheikhId,
    required this.assignedAt,
    this.isActive = true,
  });

  factory AssignmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssignmentModel(
      id: doc.id,
      childId: data['childId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      sheikhId: data['sheikhId'] ?? '',
      assignedAt: (data['assignedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'categoryId': categoryId,
      'sheikhId': sheikhId,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'isActive': isActive,
    };
  }

  AssignmentModel copyWith({
    String? id,
    String? childId,
    String? categoryId,
    String? sheikhId,
    DateTime? assignedAt,
    bool? isActive,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      categoryId: categoryId ?? this.categoryId,
      sheikhId: sheikhId ?? this.sheikhId,
      assignedAt: assignedAt ?? this.assignedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
