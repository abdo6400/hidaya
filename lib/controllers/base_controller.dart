import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base controller class for CRUD operations to reduce code duplication
abstract class BaseController<T> extends StateNotifier<AsyncValue<List<T>>> {
  BaseController() : super(const AsyncValue.loading());

  /// Load all items
  Future<void> loadItems();

  /// Add a new item, then reload list
  Future<void> addItem(T item);

  /// Update an item, then reload list
  Future<void> updateItem(T item);

  /// Delete an item, then reload list
  Future<void> deleteItem(String itemId);

  /// Helper method to handle errors and reload
  Future<void> handleOperation(Future<void> Function() operation) async {
    try {
      await operation();
      await loadItems();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Helper method to set loading state
  void setLoading() {
    state = const AsyncValue.loading();
  }

  /// Helper method to set error state
  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}
