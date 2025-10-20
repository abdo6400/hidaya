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
    on<LoadStudentsBySheikh>(_onLoadStudentsBySheikh);
    on<RemoveStudentFromSheikh>(_onRemoveStudentFromSheikh);
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
      await emit.forEach<List<Student>>(
        _studentRepository.getAllStudentsWithStats(),
        onData: (students) => StudentsLoaded(students),
        onError: (error, stackTrace) => StudentsError(error.toString()),
      );
    } catch (e) {
      emit(StudentsError('فشل في إضافة الطالب: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateStudent(
    UpdateStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      await _studentRepository.updateStudent(event.student);
      await emit.forEach<List<Student>>(
        _studentRepository.getAllStudentsWithStats(),
        onData: (students) => StudentsLoaded(students),
        onError: (error, stackTrace) => StudentsError(error.toString()),
      );
    } catch (e) {
      emit(StudentsError('فشل في تحديث الطالب: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteStudent(
    DeleteStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      await _studentRepository.deleteStudent(event.studentId);
      await emit.forEach<List<Student>>(
        _studentRepository.getAllStudentsWithStats(),
        onData: (students) => StudentsLoaded(students),
        onError: (error, stackTrace) => StudentsError(error.toString()),
      );
    } catch (e) {
      emit(StudentsError('فشل في حذف الطالب: ${e.toString()}'));
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

  Future<void> _onRemoveStudentFromSheikh(
    RemoveStudentFromSheikh event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      await _studentRepository.removeStudentFromSheikh(event.studentId);
      emit(const StudentOperationSuccess('تم إزالة الطالب من الشيخ بنجاح'));
    } catch (e) {
      emit(
        StudentOperationError('فشل في إزالة الطالب من الشيخ: ${e.toString()}'),
      );
    }
  }
}
