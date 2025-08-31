import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? parentId; // null = main category, not null = subcategory

  CategoryModel({required this.id, required this.name, required this.description, this.parentId});

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      parentId: data['parentId'], // can be null
    );
  }

  CategoryModel copyWith({String? id, String? name, String? description, String? parentId}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'parentId': parentId};
  }

  bool get isParent => parentId == null;
  bool get isChild => parentId != null;
}
