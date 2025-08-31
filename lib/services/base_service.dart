import 'package:cloud_firestore/cloud_firestore.dart';

/// Base service class for Firestore CRUD operations to reduce code duplication
abstract class BaseService<T> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  /// Get the collection name for this service
  String get collectionName;
  
  /// Convert a document to model
  T fromFirestore(DocumentSnapshot doc);
  
  /// Convert model to map for Firestore
  Map<String, dynamic> toMap(T item);
  
  /// Get the ID from the model
  String getId(T item);

  /// Get all items
  Future<List<T>> getAll() async {
    final snapshot = await _db.collection(collectionName).get();
    return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
  }

  /// Get items by field value
  Future<List<T>> getByField(String field, dynamic value) async {
    final snapshot = await _db.collection(collectionName).where(field, isEqualTo: value).get();
    return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
  }

  /// Add a new item
  Future<void> add(T item) async {
    await _db.collection(collectionName).add(toMap(item));
  }

  /// Update an existing item
  Future<void> update(T item) async {
    await _db.collection(collectionName).doc(getId(item)).update(toMap(item));
  }

  /// Delete an item by ID
  Future<void> delete(String itemId) async {
    await _db.collection(collectionName).doc(itemId).delete();
  }

  /// Get an item by ID
  Future<T?> getById(String itemId) async {
    final doc = await _db.collection(collectionName).doc(itemId).get();
    if (doc.exists) {
      return fromFirestore(doc);
    }
    return null;
  }
}
