import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/controllers/tasks_controller.dart';
import 'package:hidaya/controllers/category_controller.dart';
import 'package:hidaya/models/task_model.dart';
import 'package:hidaya/models/category_model.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:quickalert/quickalert.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.assignment,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إدارة المهام التعليمية',
                              style: AppTheme.islamicTitleStyle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إنشاء وإدارة المهام التعليمية وتعيينها للطلاب',
                              style: AppTheme.arabicTextStyle.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Stats
          SliverToBoxAdapter(
            child: tasksAsync.when(
              data: (tasks) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'إجمالي المهام',
                        '${tasks.length}',
                        Icons.assignment,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'المهام النشطة',
                        '${tasks.length}',
                        Icons.play_circle,
                        AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'المهام المكتملة',
                        '0',
                        Icons.check_circle,
                        AppTheme.infoColor,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const LoadingIndicator(),
              error: (error, stack) => app_error.AsyncErrorWidget(
                error: error,
                stackTrace: stack,
                onRetry: () => ref.refresh(taskControllerProvider),
              ),
            ),
          ),

          // Tasks List
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'قائمة المهام',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddTaskDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة مهمة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tasks List
                  tasksAsync.when(
                    data: (tasks) => tasks.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: tasks
                                .map((task) => _buildTaskCard(task))
                                .toList(),
                          ),
                    loading: () => const LoadingIndicator(),
                    error: (error, stack) => app_error.AsyncErrorWidget(
                      error: error,
                      stackTrace: stack,
                      onRetry: () => ref.refresh(taskControllerProvider),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        margin: EdgeInsets.all(2),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assignment,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'النوع: ${_getTaskTypeText(task.type)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, task),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('تعديل'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text(
                            'حذف',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Task Details
              Row(
                children: [
                  Expanded(
                    child: _buildTaskDetail(
                      'النقاط القصوى',
                      '${task.maxPoints}',
                      Icons.star,
                      AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final categoriesAsync = ref.watch(categoryControllerProvider);
                        return categoriesAsync.when(
                          data: (categories) {
                            final category = categories.firstWhere(
                              (cat) => cat.id == task.categoryId,
                              orElse: () => CategoryModel(id: '', name: 'غير محدد', description: ''),
                            );
                            return _buildTaskDetail(
                              'الفئة',
                              category.name,
                              Icons.category,
                              AppTheme.infoColor,
                            );
                          },
                          loading: () => _buildTaskDetail(
                            'الفئة',
                            'جاري التحميل...',
                            Icons.category,
                            AppTheme.infoColor,
                          ),
                          error: (error, stack) => _buildTaskDetail(
                            'الفئة',
                            'خطأ في التحميل',
                            Icons.category,
                            AppTheme.infoColor,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              // Show custom options for custom task type
              if (task.type == TaskType.custom && task.customOptions != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.list_alt,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'الخيارات المخصصة:',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.customOptions!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskDetail(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد مهام بعد',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإضافة مهمة جديدة للبدء',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _getTaskTypeText(TaskType type) {
    switch (type) {
      case TaskType.points:
        return 'نقاط';
      case TaskType.yesNo:
        return 'نعم/لا';
      case TaskType.custom:
        return 'مخصص';
    }
  }

  void _handleMenuAction(String action, TaskModel task) {
    switch (action) {
      case 'edit':
        _showEditTaskDialog(task);
        break;
      case 'delete':
        _showDeleteConfirmation(task);
        break;
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final maxPointsController = TextEditingController(text: '10');
    final customOptionsController = TextEditingController();
    TaskType selectedType = TaskType.points;
    String? selectedCategoryId;
    bool showMaxPoints = true; // Default to points type
    bool showCustomOptions = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('إضافة مهمة جديدة'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان المهمة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Selection
                  Consumer(
                    builder: (context, ref, child) {
                      final categoriesAsync = ref.watch(categoryControllerProvider);
                      return categoriesAsync.when(
                        data: (categories) => DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'الفئة',
                            border: OutlineInputBorder(),
                            helperText: 'اختر فئة للمهمة (اختياري)',
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('بدون فئة'),
                            ),
                            ...categories.map((category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCategoryId = value;
                            });
                          },
                        ),
                        loading: () => DropdownButtonFormField<String>(
                          value: null,
                          decoration: const InputDecoration(
                            labelText: 'الفئة',
                            border: OutlineInputBorder(),
                            helperText: 'جاري تحميل الفئات...',
                          ),
                          items: [],
                          onChanged: (value) {},
                        ),
                        error: (error, stack) => DropdownButtonFormField<String>(
                          value: null,
                          decoration: const InputDecoration(
                            labelText: 'الفئة',
                            border: OutlineInputBorder(),
                            helperText: 'خطأ في تحميل الفئات',
                          ),
                          items: [],
                          onChanged: (value) {},
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TaskType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'نوع المهمة',
                      border: OutlineInputBorder(),
                    ),
                    items: TaskType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getTaskTypeText(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                          // Show different fields based on task type
                          showMaxPoints = value == TaskType.points;
                          showCustomOptions = value == TaskType.custom;
                          
                          // Update max points controller with appropriate default
                          if (value == TaskType.yesNo) {
                            maxPointsController.text = '2';
                          } else if (value == TaskType.custom) {
                            maxPointsController.text = '5';
                          } else if (value == TaskType.points) {
                            maxPointsController.text = '10';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Show max points field only for points type
                  if (showMaxPoints) ...[
                    TextField(
                      controller: maxPointsController,
                      decoration: const InputDecoration(
                        labelText: 'النقاط القصوى',
                        border: OutlineInputBorder(),
                        helperText: 'أقصى عدد من النقاط التي يمكن الحصول عليها',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Show custom options field only for custom type
                  if (showCustomOptions) ...[
                    TextField(
                      controller: customOptionsController,
                      decoration: const InputDecoration(
                        labelText: 'خيارات مخصصة',
                        border: OutlineInputBorder(),
                        helperText: '(مثال: ممتاز، جيد، مقبول، ضعيف)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Show task type description
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getTaskTypeIcon(selectedType),
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getTaskTypeDescription(selectedType),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    // Validate based on task type
                    if (selectedType == TaskType.points) {
                      if (maxPointsController.text.isEmpty || 
                          int.tryParse(maxPointsController.text) == null ||
                          int.parse(maxPointsController.text) <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى إدخال عدد صحيح موجب للنقاط القصوى'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }
                    
                    if (selectedType == TaskType.custom) {
                      if (customOptionsController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى إدخال الخيارات المخصصة'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }

                    final task = TaskModel(
                      id: '',
                      title: titleController.text,
                      type: selectedType,
                      categoryId: selectedCategoryId,
                      maxPoints: selectedType == TaskType.points 
                          ? int.tryParse(maxPointsController.text) ?? 10
                          : (selectedType == TaskType.yesNo ? 2 : 5), // Default values for other types
                      customOptions: selectedType == TaskType.custom 
                          ? customOptionsController.text 
                          : null,
                    );

                    await ref.read(taskControllerProvider.notifier).addItem(task);
                    Navigator.pop(context);
                    
                    // Show success message with task type info
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم إضافة مهمة ${_getTaskTypeText(selectedType)} بنجاح'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTaskDialog(TaskModel task) {
    final titleController = TextEditingController(text: task.title);
    final maxPointsController = TextEditingController(
      text: task.maxPoints.toString(),
    );
    final customOptionsController = TextEditingController(
      text: task.customOptions ?? '',
    );
    TaskType selectedType = task.type;
    String? selectedCategoryId = task.categoryId;
    bool showMaxPoints = task.type == TaskType.points;
    bool showCustomOptions = task.type == TaskType.custom;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تعديل المهمة'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان المهمة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Selection
                  Consumer(
                    builder: (context, ref, child) {
                      final categoriesAsync = ref.watch(categoryControllerProvider);
                      return categoriesAsync.when(
                        data: (categories) => DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'الفئة',
                            border: OutlineInputBorder(),
                            helperText: 'اختر فئة للمهمة (اختياري)',
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('بدون فئة'),
                            ),
                            ...categories.map((category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCategoryId = value;
                            });
                          },
                        ),
                        loading: () => DropdownButtonFormField<String>(
                          value: null,
                          decoration: const InputDecoration(
                            labelText: 'الفئة',
                            border: OutlineInputBorder(),
                            helperText: 'جاري تحميل الفئات...',
                          ),
                          items: [],
                          onChanged: (value) {},
                        ),
                        error: (error, stack) => DropdownButtonFormField<String>(
                          value: null,
                          decoration: const InputDecoration(
                            labelText: 'الفئة',
                            border: OutlineInputBorder(),
                            helperText: 'خطأ في تحميل الفئات',
                          ),
                          items: [],
                          onChanged: (value) {},
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TaskType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'نوع المهمة',
                      border: OutlineInputBorder(),
                    ),
                    items: TaskType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getTaskTypeText(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                          // Show different fields based on task type
                          showMaxPoints = value == TaskType.points;
                          showCustomOptions = value == TaskType.custom;
                          
                          // Update max points controller with appropriate default
                          if (value == TaskType.yesNo) {
                            maxPointsController.text = '2';
                          } else if (value == TaskType.custom) {
                            maxPointsController.text = '5';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Show max points field only for points type
                  if (showMaxPoints) ...[
                    TextField(
                      controller: maxPointsController,
                      decoration: const InputDecoration(
                        labelText: 'النقاط القصوى',
                        border: OutlineInputBorder(),
                        helperText: 'أقصى عدد من النقاط التي يمكن الحصول عليها',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Show custom options field only for custom type
                  if (showCustomOptions) ...[
                    TextField(
                      controller: customOptionsController,
                      decoration: const InputDecoration(
                        labelText: 'خيارات مخصصة',
                        border: OutlineInputBorder(),
                        helperText: 'أدخل الخيارات مفصولة بفاصلة (مثال: ممتاز، جيد، مقبول، ضعيف)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Show task type description
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getTaskTypeIcon(selectedType),
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getTaskTypeDescription(selectedType),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    // Validate based on task type
                    if (selectedType == TaskType.points) {
                      if (maxPointsController.text.isEmpty || 
                          int.tryParse(maxPointsController.text) == null ||
                          int.parse(maxPointsController.text) <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى إدخال عدد صحيح موجب للنقاط القصوى'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }
                    
                    if (selectedType == TaskType.custom) {
                      if (customOptionsController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى إدخال الخيارات المخصصة'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }

                    final updatedTask = TaskModel(
                      id: task.id,
                      title: titleController.text,
                      type: selectedType,
                      categoryId: selectedCategoryId,
                      maxPoints: selectedType == TaskType.points 
                          ? int.tryParse(maxPointsController.text) ?? 10
                          : (selectedType == TaskType.yesNo ? 2 : 5), // Default values for other types
                      customOptions: selectedType == TaskType.custom 
                          ? customOptionsController.text 
                          : null,
                    );

                    await ref
                        .read(taskControllerProvider.notifier)
                        .updateItem(updatedTask);
                    Navigator.pop(context);
                    
                    // Show success message with task type info
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تحديث مهمة ${_getTaskTypeText(selectedType)} بنجاح'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.points:
        return Icons.stars;
      case TaskType.yesNo:
        return Icons.check_circle_outline;
      case TaskType.custom:
        return Icons.list_alt;
    }
  }

  String _getTaskTypeDescription(TaskType type) {
    switch (type) {
      case TaskType.points:
        return 'مهمة بنظام النقاط - يمكن للطالب الحصول على نقاط من 0 إلى النقاط القصوى';
      case TaskType.yesNo:
        return 'مهمة نعم/لا - إما أن يكمل الطالب المهمة أو لا (نقطتان)';
      case TaskType.custom:
        return 'مهمة مخصصة - يمكن تحديد خيارات تقييم مخصصة';
    }
  }

  void _showDeleteConfirmation(TaskModel task) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'تأكيد الحذف',
      text: 'هل أنت متأكد من حذف المهمة "${task.title}"؟',
      confirmBtnText: 'حذف',
      cancelBtnText: 'إلغاء',
      onConfirmBtnTap: () async {
        await ref.read(taskControllerProvider.notifier).deleteItem(task.id);
        Navigator.pop(context);
      },
    );
  }
}
