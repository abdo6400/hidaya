import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/task_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db.collection('categories').get();
    return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _db.collection('categories').add(category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db.collection('categories').doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db.collection('categories').doc(categoryId).delete();
  }

  // Tasks
  Future<List<TaskModel>> getTasks() async {
    final snapshot = await _db.collection('tasks').get();
    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
  }

  Future<List<TaskModel>> getTasksByCategory(String categoryId) async {
    final snapshot = await _db.collection('tasks').where('categoryId', isEqualTo: categoryId).get();
    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
  }

  Future<void> addTask(TaskModel task) async {
    await _db.collection('tasks').add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    await _db.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }
}
