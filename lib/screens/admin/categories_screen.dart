import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/category_controller.dart';
import 'package:hidaya/models/category_model.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String _searchQuery = "";

  void _showCategoryDialog({CategoryModel? category}) {
    final nameController = TextEditingController(text: category?.name ?? "");
    final descController = TextEditingController(text: category?.description ?? "");

    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(category == null ? "إضافة تصنيف" : "تعديل تصنيف"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "اسم التصنيف"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "الوصف"),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
              ElevatedButton(
                onPressed: () async {
                  final controller = ref.read(categoryControllerProvider.notifier);
                  if (category == null) {
                    // Add new
                    await controller.addCategory(
                      CategoryModel(
                        id: "", // Firestore will assign
                        name: nameController.text.trim(),
                        description: descController.text.trim(),
                      ),
                    );
                  } else {
                    // Update existing
                    await controller.updateCategory(
                      category.copyWith(
                        name: nameController.text.trim(),
                        description: descController.text.trim(),
                      ),
                    );
                  }
                  if (mounted) Navigator.pop(ctx);
                },
                child: Text(category == null ? "إضافة" : "تعديل"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("حذف تصنيف"),
          content: Text("هل أنت متأكد من حذف '${category.name}'؟"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await ref.read(categoryControllerProvider.notifier).deleteCategory(category.id);
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text("حذف"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "ابحث عن تصنيف...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                final filtered = categories
                    .where(
                      (c) =>
                          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          c.description.toLowerCase().contains(_searchQuery.toLowerCase()),
                    )
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("لا يوجد تصنيفات"));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    return Card(
                      child: ListTile(
                        title: Text(category.name),
                        subtitle: category.description.isNotEmpty
                            ? Text(category.description, style: const TextStyle(color: Colors.grey))
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showCategoryDialog(category: category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(category),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("حدث خطأ: $e")),
            ),
          ),
        ],
      ),
    );
  }
}
