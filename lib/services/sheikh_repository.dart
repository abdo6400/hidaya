import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sheikh.dart';
import 'firebase_service.dart';

class SheikhRepository {
  final CollectionReference _collection = FirebaseService.sheikhsRef;

  // Create sheikh
  Future<String> createSheikh(Sheikh sheikh) async {
    try {
      final docRef = await _collection.add(sheikh.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create sheikh: $e');
    }
  }

  // Add sheikh (alias for createSheikh)
  Future<void> addSheikh(Sheikh sheikh) async {
    try {
      await _collection.doc(sheikh.id).set(sheikh.toMap());
    } catch (e) {
      throw Exception('Failed to add sheikh: $e');
    }
  }

  // Get all sheikhs
  Stream<List<Sheikh>> getAllSheikhs() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Sheikh.fromMap(data);
      }).toList();
    });
  }

  // Get sheikh by ID
  Future<Sheikh?> getSheikhById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Sheikh.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get sheikh: $e');
    }
  }

  // Update sheikh
  Future<void> updateSheikh(Sheikh sheikh) async {
    try {
      await _collection.doc(sheikh.id).update(sheikh.toMap());
    } catch (e) {
      throw Exception('Failed to update sheikh: $e');
    }
  }

  // Delete sheikh
  Future<void> deleteSheikh(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete sheikh: $e');
    }
  }

  // Update sheikh student count
  Future<void> updateSheikhStudentCount(String sheikhId, int count) async {
    try {
      await _collection.doc(sheikhId).update({
        'studentCount': FieldValue.increment(count),
        'updatedAt': FirebaseService.currentTimestamp,
      });
    } catch (e) {
      throw Exception('Failed to update sheikh student count: $e');
    }
  }
}
