import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/tasks_controller.dart';
import '../../models/task_model.dart';
import '../../models/category_model.dart';
import '../../controllers/category_controller.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TasksScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _maxPointsController = TextEditingController();
  final _searchController = TextEditingController();

  String? _selectedCategoryId;
  TaskType _selectedTaskType = TaskType.points;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _showAddEditDialog({TaskModel? task, required List<CategoryModel> categories}) {
    if (task != null) {
      _titleController.text = task.title;
      _maxPointsController.text = task.maxPoints.toString();
      _selectedCategoryId = task.categoryId;
      _selectedTaskType = task.type;
    } else {
      _titleController.clear();
      _maxPointsController.text = '10';
      _selectedCategoryId = null;
      _selectedTaskType = TaskType.points;
    }

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(task == null ? 'إضافة مهمة' : 'تعديل مهمة'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'الرجاء إدخال العنوان' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskType>(
                      value: _selectedTaskType,
                      decoration: const InputDecoration(
                        labelText: 'نوع المهمة',
                        border: OutlineInputBorder(),
                      ),
                      items: TaskType.values.map((type) {
                        return DropdownMenuItem(value: type, child: Text(_getTaskTypeLabel(type)));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            _selectedTaskType = value;
                            if (value == TaskType.yesNo) {
                              _maxPointsController.text = '1';
                            } else if (_maxPointsController.text == '1') {
                              _maxPointsController.text = '10';
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selectedTaskType != TaskType.yesNo)
                      TextFormField(
                        controller: _maxPointsController,
                        decoration: const InputDecoration(
                          labelText: 'الحد الأقصى للنقاط',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final points = int.tryParse(value ?? '');
                          if (points == null || points <= 0) {
                            return 'أدخل رقمًا صحيحًا';
                          }
                          return null;
                        },
                      ),
                    if (_selectedTaskType == TaskType.yesNo)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'مهمة نعم/لا تكون النقاط فيها 1 لـ نعم و 0 لـ لا',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'التصنيف (اختياري)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('بدون')),
                        ...categories.map((category) {
                          return DropdownMenuItem(value: category.id, child: Text(category.name));
                        }),
                      ],
                      onChanged: (value) => setDialogState(() => _selectedCategoryId = value),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final maxPoints = _selectedTaskType == TaskType.yesNo
                        ? 1
                        : int.parse(_maxPointsController.text);

                    final newTask = TaskModel(
                      id: task?.id ?? '',
                      title: _titleController.text.trim(),
                      type: _selectedTaskType,
                      categoryId: _selectedCategoryId,
                      maxPoints: maxPoints,
                    );

                    final controller = ref.read(taskControllerProvider.notifier);

                    if (task == null) {
                      await controller.addTask(newTask);
                    } else {
                      await controller.updateTask(newTask);
                    }

                    if (mounted) Navigator.pop(context);
                  }
                },
                child: Text(task == null ? 'إضافة' : 'تعديل'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTaskTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.points:
        return 'نقاط (١-١٠)';
      case TaskType.yesNo:
        return 'نعم/لا';
      case TaskType.custom:
        return 'نقاط مخصصة';
    }
  }

  String _getCategoryName(String? categoryId, List<CategoryModel> categories) {
    if (categoryId == null) return 'بدون تصنيف';
    return categories
        .firstWhere(
          (c) => c.id == categoryId,
          orElse: () => CategoryModel(id: '', name: 'غير معروف', description: ''),
        )
        .name;
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskControllerProvider);
    final categoriesAsync = ref.watch(categoryControllerProvider);

    return Scaffold(
      floatingActionButton: categoriesAsync.when(
        data: (categories) => FloatingActionButton(
          heroTag: null,
          onPressed: () => _showAddEditDialog(categories: categories),
          child: const Icon(Icons.add),
        ),
        loading: () => const SizedBox(),
        error: (_, __) => const SizedBox(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "ابحث عن مهمة...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) => categoriesAsync.when(
                data: (categories) {
                  // 🔎 Apply search filter
                  final filteredTasks = tasks.where((t) {
                    return t.title.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return const Center(child: Text("لا توجد مهام مطابقة"));
                  }

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    padding: EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('النوع: ${_getTaskTypeLabel(task.type)}'),
                              Text('التصنيف: ${_getCategoryName(task.categoryId, categories)}'),
                              if (task.type == TaskType.yesNo)
                                const Text('التقييم: نعم = ١ نقطة ، لا = ٠ نقاط')
                              else
                                Text('الحد الأقصى للنقاط: ${task.maxPoints}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _showAddEditDialog(task: task, categories: categories),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('حذف مهمة'),
                                    content: Text('هل تريد حذف "${task.title}"؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('إلغاء'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () async {
                                          Navigator.pop(ctx);
                                          await ref
                                              .read(taskControllerProvider.notifier)
                                              .deleteTask(task.id);
                                        },
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("خطأ في تحميل التصنيفات: $e")),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("خطأ في تحميل المهام: $e")),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _maxPointsController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
