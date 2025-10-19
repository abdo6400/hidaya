import 'package:equatable/equatable.dart';
import '../../models/result.dart';

abstract class ResultsState extends Equatable {
  const ResultsState();

  @override
  List<Object?> get props => [];
}

class ResultsInitial extends ResultsState {
  const ResultsInitial();
}

class ResultsLoading extends ResultsState {
  const ResultsLoading();
}

class ResultsLoaded extends ResultsState {
  final List<Result> results;

  const ResultsLoaded(this.results);

  @override
  List<Object?> get props => [results];
}

class ResultsError extends ResultsState {
  final String message;

  const ResultsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ResultOperationSuccess extends ResultsState {
  final String message;

  const ResultOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ResultOperationError extends ResultsState {
  final String message;

  const ResultOperationError(this.message);

  @override
  List<Object?> get props => [message];
}
