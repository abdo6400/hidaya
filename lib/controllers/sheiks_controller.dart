import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/sheiks_service.dart';

final sheiksControllerProvider = StateNotifierProvider<SheiksController, AsyncValue<List<AppUser>>>(
  (ref) => SheiksController(SheiksService()),
);

class SheiksController extends StateNotifier<AsyncValue<List<AppUser>>> {
  final SheiksService _sheiksService;
  SheiksController(this._sheiksService) : super(const AsyncValue.loading());

  Future<void> loadSheikhs() async {
    state = const AsyncValue.loading();
    try {
      final sheikhs = await _sheiksService.getAllSheikhs();
      state = AsyncValue.data(sheikhs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSheikh({
    required String username,
    required String password,
    required String phone,
    required String status,
  }) async {
    try {
      final sheikh = await _sheiksService.addSheikh(
        username: username,
        password: password,
        phone: phone,
        status: status,
      );
      if (sheikh != null) {
        state.whenData((list) => state = AsyncValue.data([...list, sheikh]));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSheikh(String sheikhId, Map<String, dynamic> data) async {
    try {
      await _sheiksService.updateSheikh(sheikhId, data);
      await loadSheikhs();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> activateSheikh(String sheikhId) async {
    try {
      await _sheiksService.activateSheikh(sheikhId);
      await loadSheikhs();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deactivateSheikh(String sheikhId) async {
    try {
      await _sheiksService.deactivateSheikh(sheikhId);
      await loadSheikhs();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSheikh(String sheikhId) async {
    try {
      await _sheiksService.deleteSheikh(sheikhId);
      state.whenData(
        (list) => state = AsyncValue.data(list.where((s) => s.id != sheikhId).toList()),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  
}
