import 'package:equatable/equatable.dart';
import '../../models/result.dart';

abstract class ResultsEvent extends Equatable {
  const ResultsEvent();

  @override
  List<Object?> get props => [];
}

class LoadResults extends ResultsEvent {
  const LoadResults();
}

class AddResult extends ResultsEvent {
  final Result result;

  const AddResult(this.result);

  @override
  List<Object?> get props => [result];
}

class UpdateResult extends ResultsEvent {
  final Result result;

  const UpdateResult(this.result);

  @override
  List<Object?> get props => [result];
}

class DeleteResult extends ResultsEvent {
  final String resultId;

  const DeleteResult(this.resultId);

  @override
  List<Object?> get props => [resultId];
}

class LoadResultsByStudent extends ResultsEvent {
  final String studentId;

  const LoadResultsByStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadResultsByTask extends ResultsEvent {
  final String taskId;

  const LoadResultsByTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class LoadResultsByDateRange extends ResultsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadResultsByDateRange(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}
