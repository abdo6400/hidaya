import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/models/user_model.dart';
import '../../controllers/assign_children_controller.dart';
import '../../models/child_model.dart';
import '../../models/category_model.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/sheiks_controller.dart';
import '../../controllers/assignments_controller.dart';

class AssignChildScreen extends ConsumerStatefulWidget {
  const AssignChildScreen({super.key});

  @override
  ConsumerState<AssignChildScreen> createState() => _AssignChildScreenState();
}

class _AssignChildScreenState extends ConsumerState<AssignChildScreen> {
  ChildModel? selectedChild;
  CategoryModel? selectedCategory;
  AppUser? selectedSheikh;

  @override
  Widget build(BuildContext context) {
    // Get the async values from the providers
    final categoriesAsyncValue = ref.watch(categoryControllerProvider);
    final sheikhsAsyncValue = ref.watch(sheiksControllerProvider);
    final childrenAsyncValue = ref.watch(assignChildrenControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Child')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Child Dropdown
            childrenAsyncValue.when(
              data: (children) => DropdownButtonFormField<ChildModel>(
                value: selectedChild,
                hint: const Text('Select Child'),
                items: children.map((child) {
                  return DropdownMenuItem(
                    value: child,
                    child: Text(child.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedChild = value;
                  });
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            categoriesAsyncValue.when(
              data: (categories) => DropdownButtonFormField<CategoryModel>(
                value: selectedCategory,
                hint: const Text('Select Category'),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 16),

            // Sheikh Dropdown
            sheikhsAsyncValue.when(
              data: (sheikhs) => DropdownButtonFormField<AppUser>(
                value: selectedSheikh,
                hint: const Text('Select Sheikh'),
                items: sheikhs.map((sheikh) {
                  return DropdownMenuItem(
                    value: sheikh,
                    child: Text(sheikh.username),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSheikh = value;
                  });
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 24),

            // Assign Button
            ElevatedButton(
              onPressed:
                  (selectedChild != null &&
                      selectedCategory != null &&
                      selectedSheikh != null)
                  ? () => _assignChild()
                  : null,
              child: const Text('Assign Child'),
            ),
          ],
        ),
      ),
    );
  }

  void _assignChild() async {
    if (selectedChild == null ||
        selectedCategory == null ||
        selectedSheikh == null) {
      return;
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Assigning child...')));

      await ref
          .read(assignmentsControllerProvider.notifier)
          .assignChild(
            childId: selectedChild!.id,
            categoryId: selectedCategory!.id,
            sheikhId: selectedSheikh!.id,
          );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child assigned successfully!')),
        );
        // Reset selections
        setState(() {
          selectedChild = null;
          selectedCategory = null;
          selectedSheikh = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error assigning child: $e')));
      }
    }
  }
}
