import 'package:equatable/equatable.dart';
import '../../models/index.dart';

abstract class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroups extends GroupsEvent {
  const LoadGroups();
}

class AddGroup extends GroupsEvent {
  final Group group;

  const AddGroup(this.group);

  @override
  List<Object?> get props => [group];
}

class UpdateGroup extends GroupsEvent {
  final Group group;

  const UpdateGroup(this.group);

  @override
  List<Object?> get props => [group];
}

class DeleteGroup extends GroupsEvent {
  final String groupId;

  const DeleteGroup(this.groupId);

  @override
  List<Object?> get props => [groupId];
}
