import 'package:equatable/equatable.dart';
import '../../models/index.dart';

abstract class SheikhsState extends Equatable {
  const SheikhsState();

  @override
  List<Object?> get props => [];
}

class SheikhsInitial extends SheikhsState {
  const SheikhsInitial();
}

class SheikhsLoading extends SheikhsState {
  const SheikhsLoading();
}

class SheikhsLoaded extends SheikhsState {
  final List<Sheikh> sheikhs;

  const SheikhsLoaded(this.sheikhs);

  @override
  List<Object?> get props => [sheikhs];
}

class SheikhsError extends SheikhsState {
  final String message;

  const SheikhsError(this.message);

  @override
  List<Object?> get props => [message];
}
