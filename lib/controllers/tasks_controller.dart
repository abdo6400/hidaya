import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/firebase_service.dart';
import 'base_controller.dart';

final taskControllerProvider =
    StateNotifierProvider<TaskController, AsyncValue<List<TaskModel>>>(
  (ref) => TaskController(FirebaseService()),
);

class TaskController extends BaseController<TaskModel> {
  final FirebaseService _firebaseService;

  TaskController(this._firebaseService) {
    loadItems();
  }

  @override
  Future<void> loadItems() async {
    setLoading();
    state = await AsyncValue.guard(() => _firebaseService.getAllTasks());
  }

  @override
  Future<void> addItem(TaskModel item) async {
    await handleOperation(() => _firebaseService.addTask(item));
  }

  @override
  Future<void> updateItem(TaskModel item) async {
    await handleOperation(() => _firebaseService.updateTask(item));
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await handleOperation(() => _firebaseService.deleteTask(itemId));
  }

  /// Load tasks for a specific category
  Future<void> loadTasksByCategory(String categoryId) async {
    setLoading();
    state = await AsyncValue.guard(() => _firebaseService.getTasksByCategory(categoryId));
  }

  // Legacy method names for backward compatibility
  Future<void> loadTasks() => loadItems();
  Future<void> addTask(TaskModel task) => addItem(task);
  Future<void> updateTask(TaskModel task) => updateItem(task);
  Future<void> deleteTask(String taskId) => deleteItem(taskId);
}
