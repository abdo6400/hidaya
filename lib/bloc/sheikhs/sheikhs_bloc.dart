import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import 'sheikhs_event.dart';
import 'sheikhs_state.dart';

class SheikhsBloc extends Bloc<SheikhsEvent, SheikhsState> {
  final SheikhRepository _sheikhRepository;

  SheikhsBloc({required SheikhRepository sheikhRepository})
      : _sheikhRepository = sheikhRepository,
        super(const SheikhsInitial()) {
    on<LoadSheikhs>(_onLoadSheikhs);
    on<AddSheikh>(_onAddSheikh);
    on<UpdateSheikh>(_onUpdateSheikh);
    on<DeleteSheikh>(_onDeleteSheikh);
  }

  Future<void> _onLoadSheikhs(
    LoadSheikhs event,
    Emitter<SheikhsState> emit,
  ) async {
    emit(const SheikhsLoading());
    try {
      await emit.forEach<List<Sheikh>>(
        _sheikhRepository.getAllSheikhs(),
        onData: (sheikhs) => SheikhsLoaded(sheikhs),
        onError: (error, stackTrace) => SheikhsError(error.toString()),
      );
    } catch (e) {
      emit(SheikhsError(e.toString()));
    }
  }

  Future<void> _onAddSheikh(
    AddSheikh event,
    Emitter<SheikhsState> emit,
  ) async {
    try {
      await _sheikhRepository.addSheikh(event.sheikh);
    } catch (e) {
      emit(SheikhsError(e.toString()));
    }
  }

  Future<void> _onUpdateSheikh(
    UpdateSheikh event,
    Emitter<SheikhsState> emit,
  ) async {
    try {
      await _sheikhRepository.updateSheikh(event.sheikh);
    } catch (e) {
      emit(SheikhsError(e.toString()));
    }
  }

  Future<void> _onDeleteSheikh(
    DeleteSheikh event,
    Emitter<SheikhsState> emit,
  ) async {
    try {
      await _sheikhRepository.deleteSheikh(event.sheikhId);
    } catch (e) {
      emit(SheikhsError(e.toString()));
    }
  }
}
