import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../services/firebase_service.dart';
import 'base_controller.dart';

final categoryControllerProvider =
    StateNotifierProvider<CategoryController, AsyncValue<List<CategoryModel>>>(
      (ref) => CategoryController(FirebaseService()),
    );

class CategoryController extends BaseController<CategoryModel> {
  final FirebaseService _firebaseService;

  CategoryController(this._firebaseService) {
    loadItems();
  }

  @override
  Future<void> loadItems() async {
    setLoading();
    state = await AsyncValue.guard(() => _firebaseService.getAllCategories());
  }

  @override
  Future<void> addItem(CategoryModel item) async {
    await handleOperation(() => _firebaseService.addCategory(item));
  }

  @override
  Future<void> updateItem(CategoryModel item) async {
    await handleOperation(() => _firebaseService.updateCategory(item));
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await handleOperation(() => _firebaseService.deleteCategory(itemId));
  }

  // Legacy method names for backward compatibility
  Future<void> loadCategories() => loadItems();
  Future<void> addCategory(CategoryModel category) => addItem(category);
  Future<void> updateCategory(CategoryModel category) => updateItem(category);
  Future<void> deleteCategory(String categoryId) => deleteItem(categoryId);
}
