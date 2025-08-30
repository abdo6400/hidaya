import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/child_model.dart';
import '../../models/category_model.dart';
import '../../models/user_model.dart';
import '../../models/schedule_model.dart';
import '../../controllers/children_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/sheiks_controller.dart';
import '../../controllers/schedules_controller.dart';
import '../../controllers/group_assignments_controller.dart';
import '../../models/group_assignment_model.dart';
import 'edit_group_screen.dart';

class GroupAssignmentScreen extends ConsumerStatefulWidget {
  const GroupAssignmentScreen({super.key});

  @override
  ConsumerState<GroupAssignmentScreen> createState() =>
      _GroupAssignmentScreenState();
}

class _GroupAssignmentScreenState extends ConsumerState<GroupAssignmentScreen> {
  CategoryModel? selectedCategory;
  AppUser? selectedSheikh;
  ScheduleModel? selectedSchedule;
  List<ChildModel> selectedChildren = [];
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsyncValue = ref.watch(childrenControllerProvider('all'));
    final categoriesAsyncValue = ref.watch(categoryControllerProvider);
    final sheikhsAsyncValue = ref.watch(sheiksControllerProvider);
    final schedulesAsyncValue = ref.watch(schedulesControllerProvider('all'));
    final groupsAsyncValue = ref.watch(groupAssignmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Group Assignment')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group Name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'Enter group name',
                ),
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
                      selectedSchedule =
                          null; // Reset schedule when category changes
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
                      selectedSchedule =
                          null; // Reset schedule when sheikh changes
                    });
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),

              // Schedule Dropdown (filtered by sheikh and category)
              if (selectedSheikh != null && selectedCategory != null)
                schedulesAsyncValue.when(
                  data: (schedules) {
                    final filteredSchedules = schedules.where((schedule) {
                      // Check if the schedule belongs to the selected sheikh
                      if (schedule.sheikhId != selectedSheikh!.id) return false;

                      // Check if any time slot in any day has the selected category
                      return schedule.days.any(
                        (day) => day.timeSlots.any(
                          (slot) => slot.categoryId == selectedCategory!.id,
                        ),
                      );
                    }).toList();

                    if (filteredSchedules.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No schedules found for selected sheikh and category. Please make sure to create a schedule first.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<ScheduleModel>(
                          value: selectedSchedule,
                          hint: const Text('Select Schedule'),
                          items: filteredSchedules.map((schedule) {
                            return DropdownMenuItem(
                              value: schedule,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: schedule.days.map((day) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: day.timeSlots
                                        .where(
                                          (slot) =>
                                              slot.categoryId ==
                                              selectedCategory!.id,
                                        )
                                        .map(
                                          (slot) => Text(
                                            '${day.day.name} ${slot.startTime}-${slot.endTime}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                }).toList(),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSchedule = value;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                        if (selectedSchedule != null) ...[
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Schedule Details:',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  Column(
                                    children: selectedSchedule!.days.expand((
                                      day,
                                    ) {
                                      return day.timeSlots
                                          .where(
                                            (slot) =>
                                                slot.categoryId ==
                                                selectedCategory!.id,
                                          )
                                          .map(
                                            (slot) => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Day: ${day.day.name}'),
                                                Text(
                                                  'Time: ${slot.startTime} - ${slot.endTime}',
                                                ),
                                              ],
                                            ),
                                          );
                                    }).toList(),
                                  ),
                                  if (selectedSchedule!.notes.isNotEmpty)
                                    Text('Notes: ${selectedSchedule!.notes}'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading schedules: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Children Multi-Select
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Children',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      childrenAsyncValue.when(
                        data: (children) => Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: children.length,
                            itemBuilder: (context, index) {
                              final child = children[index];
                              return CheckboxListTile(
                                title: Text(child.name),
                                subtitle: Text('Age: ${child.age}'),
                                value: selectedChildren.contains(child),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedChildren.add(child);
                                    } else {
                                      selectedChildren.remove(child);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) =>
                            Center(child: Text('Error: $error')),
                      ),
                      if (selectedChildren.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          '${selectedChildren.length} children selected',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Create Group Button
              ElevatedButton(
                onPressed: _canCreateGroup() ? _createGroup : null,
                child: const Text('Create Group'),
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Existing Groups List
              const Text(
                'Existing Groups',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              groupsAsyncValue.when(
                data: (groups) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Card(
                      child: ListTile(
                        title: Text(group.name),
                        subtitle: Text(
                          '${group.childrenIds.length} children assigned',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editGroup(group),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteGroup(group.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canCreateGroup() {
    return nameController.text.isNotEmpty &&
        selectedCategory != null &&
        selectedSheikh != null &&
        selectedSchedule != null &&
        selectedChildren.isNotEmpty;
  }

  void _createGroup() async {
    try {
      await ref
          .read(groupAssignmentsProvider.notifier)
          .createGroup(
            categoryId: selectedCategory!.id,
            sheikhId: selectedSheikh!.id,
            scheduleId: selectedSchedule!.id,
            childrenIds: selectedChildren.map((c) => c.id).toList(),
            name: nameController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully!')),
        );
        // Reset form
        setState(() {
          selectedCategory = null;
          selectedSheikh = null;
          selectedSchedule = null;
          selectedChildren.clear();
          nameController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating group: $e')));
      }
    }
  }

  void _editGroup(GroupAssignmentModel group) {
    // TODO: Convert GroupAssignmentModel to ScheduleGroupModel or create separate edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality - to be implemented')),
    );
  }

  void _deleteGroup(String groupId) async {
    // Show confirmation dialog
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('Are you sure you want to delete this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (delete == true && mounted) {
      try {
        await ref.read(groupAssignmentsProvider.notifier).deleteGroup(groupId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting group: $e')));
      }
    }
  }
}
