import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String id;
  final String name;
  final String age;
  final String parentId;
  final bool isApproved;
  final String createdBy;
  final DateTime? createdAt;
  final String? categoryId;
  final String? sheikhId;
  final DateTime? assignedAt;

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.parentId,
    required this.isApproved,
    required this.createdBy,
    this.createdAt,
    this.categoryId,
    this.sheikhId,
    this.assignedAt,
  });

  factory ChildModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChildModel(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? '',
      parentId: data['parentId'] ?? '',
      isApproved: data['isApproved'] ?? false,
      createdBy: data['createdBy'] ?? '',
      categoryId: data['categoryId'],
      sheikhId: data['sheikhId'],
      assignedAt: data['assignedAt'] != null
          ? DateTime.parse(data['assignedAt'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "age": age,
      "parentId": parentId,
      "isApproved": isApproved,
      "createdBy": createdBy,
      "createdAt": createdAt,
    };
  }
}
