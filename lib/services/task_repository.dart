import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'firebase_service.dart';

class TaskRepository {
  final CollectionReference _collection = FirebaseService.tasksRef;

  // Create task
  Future<String> createTask(Task task) async {
    try {
      final docRef = await _collection.add(task.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Get all tasks
  Stream<List<Task>> getAllTasks() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();
    });
  }

  // Get task by ID
  Future<Task?> getTaskById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Task.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  // Update task
  Future<void> updateTask(Task task) async {
    try {
      await _collection.doc(task.id).update(task.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Get tasks by type
  Stream<List<Task>> getTasksByType(TaskType type) {
    return _collection
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();
    });
  }
}
