import 'package:flutter_bloc/flutter_bloc.dart';
import 'students_event.dart';
import 'students_state.dart';
import '../../services/student_repository.dart';
import '../../models/student.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final StudentRepository _studentRepository;

  StudentsBloc({required StudentRepository studentRepository})
      : _studentRepository = studentRepository,
        super(const StudentsInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<AddStudent>(_onAddStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
    on<LoadStudentsByGroup>(_onLoadStudentsByGroup);
    on<LoadStudentsBySheikh>(_onLoadStudentsBySheikh);
  }

  Future<void> _onLoadStudents(
    LoadStudents event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());
    try {
      await emit.forEach<List<Student>>(
        _studentRepository.getAllStudentsWithStats(),
        onData: (students) => StudentsLoaded(students),
        onError: (error, stackTrace) => StudentsError(error.toString()),
      );
    } catch (e) {
      emit(StudentsError(e.toString()));
    }
  }

  Future<void> _onAddStudent(
    AddStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      await _studentRepository.createStudent(event.student);
      emit(const StudentOperationSuccess('تم إضافة الطالب بنجاح'));
    } catch (e) {
      emit(StudentOperationError('فشل في إضافة الطالب: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateStudent(
    UpdateStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      await _studentRepository.updateStudent(event.student);
      emit(const StudentOperationSuccess('تم تحديث الطالب بنجاح'));
    } catch (e) {
      emit(StudentOperationError('فشل في تحديث الطالب: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteStudent(
    DeleteStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      await _studentRepository.deleteStudent(event.studentId);
      emit(const StudentOperationSuccess('تم حذف الطالب بنجاح'));
    } catch (e) {
      emit(StudentOperationError('فشل في حذف الطالب: ${e.toString()}'));
    }
  }

  Future<void> _onLoadStudentsByGroup(
    LoadStudentsByGroup event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());
    try {
      await emit.forEach<List<Student>>(
        _studentRepository.getStudentsByGroup(event.groupId),
        onData: (students) => StudentsLoaded(students),
        onError: (error, stackTrace) => StudentsError(error.toString()),
      );
    } catch (e) {
      emit(StudentsError(e.toString()));
    }
  }

  Future<void> _onLoadStudentsBySheikh(
    LoadStudentsBySheikh event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());
    try {
      await emit.forEach<List<Student>>(
        _studentRepository.getStudentsBySheikh(event.sheikhId),
        onData: (students) => StudentsLoaded(students),
        onError: (error, stackTrace) => StudentsError(error.toString()),
      );
    } catch (e) {
      emit(StudentsError(e.toString()));
    }
  }
}
