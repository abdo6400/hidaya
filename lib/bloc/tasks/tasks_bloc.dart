import 'package:flutter_bloc/flutter_bloc.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';
import '../../services/task_repository.dart';
import '../../models/task.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository _taskRepository;

  TasksBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(const TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<LoadTasksByType>(_onLoadTasksByType);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TasksState> emit,
  ) async {
    emit(const TasksLoading());
    try {
      await emit.forEach<List<Task>>(
        _taskRepository.getAllTasks(),
        onData: (tasks) => TasksLoaded(tasks),
        onError: (error, stackTrace) => TasksError(error.toString()),
      );
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onAddTask(
    AddTask event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _taskRepository.createTask(event.task);
      emit(const TaskOperationSuccess('تم إضافة المهمة بنجاح'));
    } catch (e) {
      emit(TaskOperationError('فشل في إضافة المهمة: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _taskRepository.updateTask(event.task);
      emit(const TaskOperationSuccess('تم تحديث المهمة بنجاح'));
    } catch (e) {
      emit(TaskOperationError('فشل في تحديث المهمة: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _taskRepository.deleteTask(event.taskId);
      emit(const TaskOperationSuccess('تم حذف المهمة بنجاح'));
    } catch (e) {
      emit(TaskOperationError('فشل في حذف المهمة: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTasksByType(
    LoadTasksByType event,
    Emitter<TasksState> emit,
  ) async {
    emit(const TasksLoading());
    try {
      await emit.forEach<List<Task>>(
        _taskRepository.getTasksByType(event.type),
        onData: (tasks) => TasksLoaded(tasks),
        onError: (error, stackTrace) => TasksError(error.toString()),
      );
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
