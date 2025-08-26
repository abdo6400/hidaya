import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
final taskControllerProvider =
    StateNotifierProvider<TaskController, AsyncValue<List<TaskModel>>>(
  (ref) => TaskController(DatabaseService()),
);

class TaskController extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final DatabaseService _dbService;

  TaskController(this._dbService) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  /// Load all tasks
  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _dbService.getTasks());
  }

  /// Load tasks for a specific category
  Future<void> loadTasksByCategory(String categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _dbService.getTasksByCategory(categoryId));
  }

  /// Add a new task and reload list
  Future<void> addTask(TaskModel task) async {
    try {
      await _dbService.addTask(task);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update a task and reload list
  Future<void> updateTask(TaskModel task) async {
    try {
      await _dbService.updateTask(task);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a task and reload list
  Future<void> deleteTask(String taskId) async {
    try {
      await _dbService.deleteTask(taskId);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
