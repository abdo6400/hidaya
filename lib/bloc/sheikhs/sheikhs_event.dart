import 'package:equatable/equatable.dart';
import '../../models/index.dart';

abstract class SheikhsEvent extends Equatable {
  const SheikhsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSheikhs extends SheikhsEvent {
  const LoadSheikhs();
}

class AddSheikh extends SheikhsEvent {
  final Sheikh sheikh;

  const AddSheikh(this.sheikh);

  @override
  List<Object?> get props => [sheikh];
}

class UpdateSheikh extends SheikhsEvent {
  final Sheikh sheikh;

  const UpdateSheikh(this.sheikh);

  @override
  List<Object?> get props => [sheikh];
}

class DeleteSheikh extends SheikhsEvent {
  final String sheikhId;

  const DeleteSheikh(this.sheikhId);

  @override
  List<Object?> get props => [sheikhId];
}
