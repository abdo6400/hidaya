import 'package:equatable/equatable.dart';
import '../../models/task.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {
  const TasksInitial();
}

class TasksLoading extends TasksState {
  const TasksLoading();
}

class TasksLoaded extends TasksState {
  final List<Task> tasks;

  const TasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskOperationSuccess extends TasksState {
  final String message;

  const TaskOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskOperationError extends TasksState {
  final String message;

  const TaskOperationError(this.message);

  @override
  List<Object?> get props => [message];
}
