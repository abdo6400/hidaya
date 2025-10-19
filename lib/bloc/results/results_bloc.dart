import 'package:flutter_bloc/flutter_bloc.dart';
import 'results_event.dart';
import 'results_state.dart';
import '../../services/result_repository.dart';
import '../../models/result.dart';

class ResultsBloc extends Bloc<ResultsEvent, ResultsState> {
  final ResultRepository _resultRepository;

  ResultsBloc({required ResultRepository resultRepository})
      : _resultRepository = resultRepository,
        super(const ResultsInitial()) {
    on<LoadResults>(_onLoadResults);
    on<AddResult>(_onAddResult);
    on<UpdateResult>(_onUpdateResult);
    on<DeleteResult>(_onDeleteResult);
    on<LoadResultsByStudent>(_onLoadResultsByStudent);
    on<LoadResultsByTask>(_onLoadResultsByTask);
    on<LoadResultsByDateRange>(_onLoadResultsByDateRange);
  }

  Future<void> _onLoadResults(
    LoadResults event,
    Emitter<ResultsState> emit,
  ) async {
    emit(const ResultsLoading());
    try {
      await emit.forEach<List<Result>>(
        _resultRepository.getAllResults(),
        onData: (results) => ResultsLoaded(results),
        onError: (error, stackTrace) => ResultsError(error.toString()),
      );
    } catch (e) {
      emit(ResultsError(e.toString()));
    }
  }

  Future<void> _onAddResult(
    AddResult event,
    Emitter<ResultsState> emit,
  ) async {
    try {
      await _resultRepository.createResult(event.result);
      emit(const ResultOperationSuccess('تم إضافة النتيجة بنجاح'));
    } catch (e) {
      emit(ResultOperationError('فشل في إضافة النتيجة: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateResult(
    UpdateResult event,
    Emitter<ResultsState> emit,
  ) async {
    try {
      await _resultRepository.updateResult(event.result);
      emit(const ResultOperationSuccess('تم تحديث النتيجة بنجاح'));
    } catch (e) {
      emit(ResultOperationError('فشل في تحديث النتيجة: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteResult(
    DeleteResult event,
    Emitter<ResultsState> emit,
  ) async {
    try {
      await _resultRepository.deleteResult(event.resultId);
      emit(const ResultOperationSuccess('تم حذف النتيجة بنجاح'));
    } catch (e) {
      emit(ResultOperationError('فشل في حذف النتيجة: ${e.toString()}'));
    }
  }

  Future<void> _onLoadResultsByStudent(
    LoadResultsByStudent event,
    Emitter<ResultsState> emit,
  ) async {
    emit(const ResultsLoading());
    try {
      await emit.forEach<List<Result>>(
        _resultRepository.getResultsByStudent(event.studentId),
        onData: (results) => ResultsLoaded(results),
        onError: (error, stackTrace) => ResultsError(error.toString()),
      );
    } catch (e) {
      emit(ResultsError(e.toString()));
    }
  }

  Future<void> _onLoadResultsByTask(
    LoadResultsByTask event,
    Emitter<ResultsState> emit,
  ) async {
    emit(const ResultsLoading());
    try {
      await emit.forEach<List<Result>>(
        _resultRepository.getResultsByTask(event.taskId),
        onData: (results) => ResultsLoaded(results),
        onError: (error, stackTrace) => ResultsError(error.toString()),
      );
    } catch (e) {
      emit(ResultsError(e.toString()));
    }
  }

  Future<void> _onLoadResultsByDateRange(
    LoadResultsByDateRange event,
    Emitter<ResultsState> emit,
  ) async {
    emit(const ResultsLoading());
    try {
      await emit.forEach<List<Result>>(
        _resultRepository.getResultsByDateRange(event.startDate, event.endDate),
        onData: (results) => ResultsLoaded(results),
        onError: (error, stackTrace) => ResultsError(error.toString()),
      );
    } catch (e) {
      emit(ResultsError(e.toString()));
    }
  }
}
