import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/child_tasks_controller.dart';
import 'package:hidaya/controllers/tasks_controller.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/task_model.dart';
import 'package:hidaya/services/group_children_service.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/primary_button.dart';

class AssignTasksScreen extends ConsumerStatefulWidget {
  final ScheduleGroupModel group;

  const AssignTasksScreen({super.key, required this.group});

  @override
  ConsumerState<AssignTasksScreen> createState() => _AssignTasksScreenState();
}

class _AssignTasksScreenState extends ConsumerState<AssignTasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedTaskIds = {};
  final Set<String> _selectedChildIds = {};
  bool _isLoading = false;
  String _searchQuery = '';
  List<ChildModel> _childrenInGroup = [];
  List<TaskModel> _availableTasks = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load children in the group
      final groupChildrenService = GroupChildrenService();
      _childrenInGroup = await groupChildrenService.getChildrenInGroup(
        widget.group.id,
      );

      // Load available tasks
      final tasksAsync = await ref.read(taskControllerProvider);
      final tasks = tasksAsync.when(
        data: (tasks) => tasks,
        loading: () => <TaskModel>[],
        error: (_, __) => <TaskModel>[],
      );
      _availableTasks = tasks
          .where((task) => task.title.toLowerCase().contains(_searchQuery))
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignSelectedTasks() async {
    if (_selectedTaskIds.isEmpty || _selectedChildIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار مهام وأطفال')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final totalAssignments =
          _selectedTaskIds.length * _selectedChildIds.length;
      int completedAssignments = 0;

      for (String taskId in _selectedTaskIds) {
        for (String childId in _selectedChildIds) {
          await ref
              .read(childTasksControllerProvider(childId).notifier)
              .assignTask(
                taskId,
                widget.group.id,
                'sheikh', // TODO: Get actual sheikh ID
              );
          completedAssignments++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تعيين $totalAssignments مهمة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تعيين المهام: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعيين مهام - ${widget.group.name}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'البحث عن مهام...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),

                // Selection Summary
                if (_selectedTaskIds.isNotEmpty || _selectedChildIds.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.blue[50],
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'تم اختيار ${_selectedTaskIds.length} مهمة و ${_selectedChildIds.length} طفل',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedTaskIds.clear();
                              _selectedChildIds.clear();
                            });
                          },
                          child: const Text('إلغاء التحديد'),
                        ),
                      ],
                    ),
                  ),

                // Content Tabs
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'المهام المتاحة'),
                            Tab(text: 'الأطفال في المجموعة'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _TasksTab(
                                tasks: _availableTasks,
                                selectedTaskIds: _selectedTaskIds,
                                onTaskSelectionChanged: (taskId, isSelected) {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedTaskIds.add(taskId);
                                    } else {
                                      _selectedTaskIds.remove(taskId);
                                    }
                                  });
                                },
                              ),
                              _ChildrenTab(
                                children: _childrenInGroup,
                                selectedChildIds: _selectedChildIds,
                                onChildSelectionChanged: (childId, isSelected) {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedChildIds.add(childId);
                                    } else {
                                      _selectedChildIds.remove(childId);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text:
                    'تعيين المهام (${_selectedTaskIds.length * _selectedChildIds.length})',
                onPressed:
                    (_selectedTaskIds.isNotEmpty &&
                        _selectedChildIds.isNotEmpty)
                    ? _assignSelectedTasks
                    : null,
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  final List<TaskModel> tasks;
  final Set<String> selectedTaskIds;
  final Function(String, bool) onTaskSelectionChanged;

  const _TasksTab({
    required this.tasks,
    required this.selectedTaskIds,
    required this.onTaskSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد مهام متاحة',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isSelected = selectedTaskIds.contains(task.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (bool? value) {
              onTaskSelectionChanged(task.id, value ?? false);
            },
            title: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('النوع: ${task.type.toString().split('.').last}'),
                Text('العلامة: ${task.maxPoints}'),
                if (task.categoryId != null) Text('الفئة: ${task.categoryId}'),
              ],
            ),
            secondary: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.assignment, color: Colors.green[700]),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      },
    );
  }
}

class _ChildrenTab extends StatelessWidget {
  final List<ChildModel> children;
  final Set<String> selectedChildIds;
  final Function(String, bool) onChildSelectionChanged;

  const _ChildrenTab({
    required this.children,
    required this.selectedChildIds,
    required this.onChildSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا يوجد أطفال في هذه المجموعة',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        final isSelected = selectedChildIds.contains(child.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (bool? value) {
              onChildSelectionChanged(child.id, value ?? false);
            },
            title: Text(
              child.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('العمر: ${child.age} سنوات'),
            secondary: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                child.name.substring(0, 1),
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      },
    );
  }
}
