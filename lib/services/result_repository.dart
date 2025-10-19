import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/result.dart';
import 'firebase_service.dart';

class ResultRepository {
  final CollectionReference _collection = FirebaseService.resultsRef;

  // Create result
  Future<String> createResult(Result result) async {
    try {
      final docRef = await _collection.add(result.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create result: $e');
    }
  }

  // Get all results
  Stream<List<Result>> getAllResults() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Result.fromMap(data);
      }).toList();
    });
  }

  // Get result by ID
  Future<Result?> getResultById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Result.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get result: $e');
    }
  }

  // Update result
  Future<void> updateResult(Result result) async {
    try {
      await _collection.doc(result.id).update(result.toMap());
    } catch (e) {
      throw Exception('Failed to update result: $e');
    }
  }

  // Delete result
  Future<void> deleteResult(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete result: $e');
    }
  }

  // Get results by student
  Stream<List<Result>> getResultsByStudent(String studentId) {
    return _collection
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Result.fromMap(data);
      }).toList();
    });
  }

  // Get results by task
  Stream<List<Result>> getResultsByTask(String taskId) {
    return _collection
        .where('taskId', isEqualTo: taskId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Result.fromMap(data);
      }).toList();
    });
  }

  // Get results by date range
  Stream<List<Result>> getResultsByDateRange(DateTime startDate, DateTime endDate) {
    return _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Result.fromMap(data);
      }).toList();
    });
  }

  // Get results by student and date range
  Stream<List<Result>> getResultsByStudentAndDateRange(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _collection
        .where('studentId', isEqualTo: studentId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Result.fromMap(data);
      }).toList();
    });
  }
}
