import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../services/database_service.dart';

final categoryControllerProvider =
    StateNotifierProvider<CategoryController, AsyncValue<List<CategoryModel>>>(
      (ref) => CategoryController(DatabaseService()),
    );

class CategoryController extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final DatabaseService _dbService;

  CategoryController(this._dbService) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  /// Load all categories
  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _dbService.getCategories());
  }

  /// Add a new category, then reload list
  Future<void> addCategory(CategoryModel category) async {
    try {
      await _dbService.addCategory(category);
      await loadCategories();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update a category, then reload list
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _dbService.updateCategory(category);
      await loadCategories();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a category, then reload list
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _dbService.deleteCategory(categoryId);
      await loadCategories();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
