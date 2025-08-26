import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String id;
  final String name;
  final String age;
  final String parentId;
  final bool isApproved;
  final String createdBy;
  final DateTime? createdAt;

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.parentId,
    required this.isApproved,
    required this.createdBy,
    this.createdAt,
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
