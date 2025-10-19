import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import 'groups_event.dart';
import 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GroupRepository _groupRepository;

  GroupsBloc({required GroupRepository groupRepository})
      : _groupRepository = groupRepository,
        super(const GroupsInitial()) {
    on<LoadGroups>(_onLoadGroups);
    on<AddGroup>(_onAddGroup);
    on<UpdateGroup>(_onUpdateGroup);
    on<DeleteGroup>(_onDeleteGroup);
  }

  Future<void> _onLoadGroups(
    LoadGroups event,
    Emitter<GroupsState> emit,
  ) async {
    emit(const GroupsLoading());
    try {
      await emit.forEach<List<Group>>(
        _groupRepository.getAllGroups(),
        onData: (groups) => GroupsLoaded(groups),
        onError: (error, stackTrace) => GroupsError(error.toString()),
      );
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onAddGroup(
    AddGroup event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await _groupRepository.addGroup(event.group);
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onUpdateGroup(
    UpdateGroup event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await _groupRepository.updateGroup(event.group);
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onDeleteGroup(
    DeleteGroup event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await _groupRepository.deleteGroup(event.groupId);
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }
}
