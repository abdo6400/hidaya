import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/child_model.dart';
import '../../models/group_assignment_model.dart';
import '../../controllers/children_controller.dart';
import '../../controllers/group_assignments_controller.dart';

class EditGroupScreen extends ConsumerStatefulWidget {
  final GroupAssignmentModel group;

  const EditGroupScreen({super.key, required this.group});

  @override
  ConsumerState<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends ConsumerState<EditGroupScreen> {
  late TextEditingController nameController;
  List<String> selectedChildrenIds = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.group.name);
    selectedChildrenIds = List.from(widget.group.childrenIds);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsyncValue = ref.watch(childrenControllerProvider('all'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Manage Children',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            childrenAsyncValue.when(
              data: (children) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  return CheckboxListTile(
                    title: Text(child.name),
                    value: selectedChildrenIds.contains(child.id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedChildrenIds.add(child.id);
                        } else {
                          selectedChildrenIds.remove(child.id);
                        }
                      });
                    },
                  );
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() async {
    try {
      final updatedGroup = widget.group.copyWith(
        name: nameController.text,
        childrenIds: selectedChildrenIds,
      );

      await ref
          .read(groupAssignmentsProvider.notifier)
          .updateGroup(updatedGroup);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating group: $e')),
        );
      }
    }
  }
}
