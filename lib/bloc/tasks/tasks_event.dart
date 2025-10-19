import 'package:equatable/equatable.dart';
import '../../models/task.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TasksEvent {
  const LoadTasks();
}

class AddTask extends TasksEvent {
  final Task task;

  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TasksEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TasksEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class LoadTasksByType extends TasksEvent {
  final TaskType type;

  const LoadTasksByType(this.type);

  @override
  List<Object?> get props => [type];
}
