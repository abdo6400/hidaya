import 'package:equatable/equatable.dart';
import '../../models/student.dart';

abstract class StudentsEvent extends Equatable {
  const StudentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudents extends StudentsEvent {
  const LoadStudents();
}

class AddStudent extends StudentsEvent {
  final Student student;

  const AddStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class UpdateStudent extends StudentsEvent {
  final Student student;

  const UpdateStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class DeleteStudent extends StudentsEvent {
  final String studentId;

  const DeleteStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadStudentsByGroup extends StudentsEvent {
  final String groupId;

  const LoadStudentsByGroup(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class LoadStudentsBySheikh extends StudentsEvent {
  final String sheikhId;

  const LoadStudentsBySheikh(this.sheikhId);

  @override
  List<Object?> get props => [sheikhId];
}
