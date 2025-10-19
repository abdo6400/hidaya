import 'package:equatable/equatable.dart';
import '../../models/student.dart';

abstract class StudentsState extends Equatable {
  const StudentsState();

  @override
  List<Object?> get props => [];
}

class StudentsInitial extends StudentsState {
  const StudentsInitial();
}

class StudentsLoading extends StudentsState {
  const StudentsLoading();
}

class StudentsLoaded extends StudentsState {
  final List<Student> students;

  const StudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class StudentsError extends StudentsState {
  final String message;

  const StudentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class StudentOperationSuccess extends StudentsState {
  final String message;

  const StudentOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class StudentOperationError extends StudentsState {
  final String message;

  const StudentOperationError(this.message);

  @override
  List<Object?> get props => [message];
}
