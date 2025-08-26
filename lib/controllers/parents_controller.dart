import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/parents_service.dart';

final parentsControllerProvider =
    StateNotifierProvider<ParentsController, AsyncValue<List<AppUser>>>(
      (ref) => ParentsController(ParentsService()),
    );

class ParentsController extends StateNotifier<AsyncValue<List<AppUser>>> {
  final ParentsService _parentsService;

  ParentsController(this._parentsService) : super(const AsyncValue.loading());

  /// Fetch all parents
  Future<void> loadParents() async {
    try {
      state = const AsyncValue.loading();
      final parents = await _parentsService.getParents();
      state = AsyncValue.data(parents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> acceptParent(String parentId) async {
    try {
      await _parentsService.updateParentStatus(parentId, "active");
      loadParents(); // refresh list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add a new parent
  Future<void> addParent(AppUser parent, String password) async {
    try {
      await _parentsService.addParent(parent, password);
      loadParents(); // refresh list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update a parent
  Future<void> updateParent(AppUser parent) async {
    try {
      await _parentsService.updateParent(parent);
      loadParents(); // refresh list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a parent
  Future<void> deleteParent(String parentId) async {
    try {
      await _parentsService.deleteParent(parentId);
      loadParents(); // refresh list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
