import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/task_model.dart';
import 'package:hidaya/providers/firebase_providers.dart';
import 'package:hidaya/utils/app_theme.dart';

class GroupTaskManagementPage extends ConsumerStatefulWidget {
  final String sheikhId;
  final ScheduleGroupModel group;
  final String timeSlot;

  const GroupTaskManagementPage({
    super.key,
    required this.sheikhId,
    required this.group,
    required this.timeSlot,
  });

  @override
  ConsumerState<GroupTaskManagementPage> createState() =>
      _GroupTaskManagementPageState();
}

class _GroupTaskManagementPageState
    extends ConsumerState<GroupTaskManagementPage> {
  String? _selectedChildId;
  String _childQuery = '';
  final Map<String, int> _taskPointsDraft = {};
  final Map<String, String> _taskNotesDraft = {};
  final Map<String, String> _taskTitleDraft = {};
  final Set<String> _editedTaskIds = {};
  final Set<String> _hasTodayResult = {};
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.group.name), elevation: 0),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChildSelector(),
                    const SizedBox(height: 16),
                    Expanded(child: _buildTasksList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildSelector() {
    return Consumer(
      builder: (context, ref, _) {
        final studentsAsync = ref.watch(
          childrenInGroupProvider(widget.group.id),
        );
        return studentsAsync.when(
          loading: () => _buildLoadingCard('جاري تحميل الطلاب...'),
          error: (e, st) => _buildErrorCard('تعذر تحميل الطلاب'),
          data: (students) {
            final filtered = students
                .where(
                  (s) =>
                      s.name.toLowerCase().contains(_childQuery.toLowerCase()),
                )
                .toList();

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                      ),
                      hintText: 'ابحث عن طالب بالاسم',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (v) => setState(() => _childQuery = v.trim()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedChildId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      labelText: 'اختر الطالب',
                      prefixIcon: Icon(
                        Icons.person_search,
                        color: AppTheme.primaryColor,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: filtered
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              c.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) async {
                      setState(() {
                        _selectedChildId = v;
                        _clearAllDrafts();
                      });
                      if (v != null) {
                        await _preloadTodayResults(v);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTasksList() {
    if (_selectedChildId == null) {
      return _buildPlaceholder(
        icon: Icons.assignment_outlined,
        title: 'اختر طالب',
        subtitle: 'لعرض المهام المتاحة للتقييم',
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final tasksAsync = ref.watch(tasksForGroupProvider(widget.group.id));
        return tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => _buildPlaceholder(
            icon: Icons.error_outline,
            title: 'تعذر تحميل المهام',
            subtitle: 'تحقق من الاتصال وحاول مرة أخرى',
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return _buildPlaceholder(
                icon: Icons.assignment_late_outlined,
                title: 'لا توجد مهام',
                subtitle: 'لم يتم إنشاء مهام لهذه المجموعة بعد',
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _buildTaskCard(task: task);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveAllTasks,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('جاري الحفظ...'),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.save_alt, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'حفظ جميع النتائج',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard({required TaskModel task}) {
    final isEdited = _editedTaskIds.contains(task.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEdited
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskHeader(task, isEdited),
            const SizedBox(height: 16),
            _buildTaskTitleInput(task),
            const SizedBox(height: 12),
            _buildTaskInput(task),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTitleInput(TaskModel task) {
    return TextField(
      controller:
          TextEditingController(text: _taskTitleDraft[task.id] ?? task.title)
            ..selection = TextSelection.collapsed(
              offset: (_taskTitleDraft[task.id] ?? task.title).length,
            ),
      decoration: InputDecoration(
        labelText: 'عنوان المهمة',
        prefixIcon: Icon(Icons.title, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (v) => setState(() {
        _taskTitleDraft[task.id] = v.trim();
        _editedTaskIds.add(task.id);
      }),
    );
  }

  Widget _buildTaskHeader(TaskModel task, bool isEdited) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getTaskTypeColor(task.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTaskTypeIcon(task.type),
            color: _getTaskTypeColor(task.type),
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (_hasTodayResult.contains(task.id))
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text(
                  'تعديل نتيجة اليوم',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (isEdited)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  'معدّل',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _preloadTodayResults(String childId) async {
    final byTask = await ref
        .read(firebaseServiceProvider)
        .getTodayResultsByChildAndTask(childId);
    setState(() {
      _hasTodayResult
        ..clear()
        ..addAll(byTask.keys);
      // Preload drafts to reflect existing results values
      byTask.forEach((taskId, result) {
        if (result.taskType == 'yesno') {
          _taskNotesDraft[taskId] = (result.points == 2) ? 'yes' : 'no';
        } else if (result.taskType == 'custom') {
          _taskNotesDraft[taskId] = result.notes ?? '';
        } else {
          _taskPointsDraft[taskId] = result.points;
        }
        if (result.taskTitle != null && result.taskTitle!.isNotEmpty) {
          _taskTitleDraft[taskId] = result.taskTitle!;
        }
      });
    });
  }

  Widget _buildTaskInput(TaskModel task) {
    if (task.type == TaskType.yesNo) {
      final current = _taskNotesDraft[task.id];
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() {
                  _taskNotesDraft[task.id] = 'yes';
                  _editedTaskIds.add(task.id);
                }),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: current == 'yes' ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: current == 'yes' ? Colors.white : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'نعم',
                        style: TextStyle(
                          color: current == 'yes' ? Colors.white : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => setState(() {
                  _taskNotesDraft[task.id] = 'no';
                  _editedTaskIds.add(task.id);
                }),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: current == 'no' ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cancel,
                        color: current == 'no' ? Colors.white : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'لا',
                        style: TextStyle(
                          color: current == 'no' ? Colors.white : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (task.type == TaskType.custom) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: TextEditingController(
            text: _taskNotesDraft[task.id] ?? '',
          ),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'أدخل ملاحظاتك حول أداء الطالب...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.edit_note, color: AppTheme.primaryColor),
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (v) => setState(() {
            _taskNotesDraft[task.id] = v;
            _editedTaskIds.add(task.id);
          }),
        ),
      );
    } else {
      final current = _taskPointsDraft[task.id] ?? 0;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'النقاط المحصلة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$current / ${task.maxPoints}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: Slider(
                min: 0,
                max: task.maxPoints.toDouble(),
                divisions: task.maxPoints,
                value: current.toDouble(),
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.primaryColor.withOpacity(0.3),
                onChanged: (v) => setState(() {
                  _taskPointsDraft[task.id] = v.round();
                  _editedTaskIds.add(task.id);
                }),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  task.maxPoints + 1,
                  (index) => Text(
                    '$index',
                    style: TextStyle(
                      color: current == index
                          ? AppTheme.primaryColor
                          : Colors.grey,
                      fontWeight: current == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveAllTasks() async {
    if (_selectedChildId == null || _editedTaskIds.isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final tasksAsync = await ref.read(
        tasksForGroupProvider(widget.group.id).future,
      );

      // Save all edited tasks
      for (final taskId in _editedTaskIds) {
        final task = tasksAsync.firstWhere((t) => t.id == taskId);

        int points = 0;
        String? notes;

        if (task.type == TaskType.yesNo) {
          notes = _taskNotesDraft[taskId] ?? 'no';
          points = notes == 'yes' ? 2 : 0;
        } else if (task.type == TaskType.custom) {
          notes = _taskNotesDraft[taskId];
          points = 0;
        } else {
          points = _taskPointsDraft[taskId] ?? 0;
        }

        await _submitSingleTaskResult(
          task: task,
          points: points,
          notes: notes,
          categoryId: task.categoryId,
        );
      }

      if (!mounted) return;

      // Clear all drafts after successful save
      _clearAllDrafts();
      _selectedChildId=null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('تم حفظ ${_editedTaskIds.length} نتيجة بنجاح'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              const Text('حدث خطأ أثناء الحفظ'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _submitSingleTaskResult({
    required TaskModel task,
    required int points,
    required String? notes,
    required String? categoryId,
  }) async {
    await ref
        .read(firebaseServiceProvider)
        .submitTaskResult(
          _selectedChildId!,
          task.id,
          points,
          notes,
          dateISO: DateTime.now().toIso8601String().substring(0, 10),
          groupId: widget.group.id,
          categoryId: categoryId,
          sheikhId: widget.sheikhId,
          taskTitle: _taskTitleDraft[task.id]?.isNotEmpty == true
              ? _taskTitleDraft[task.id]
              : task.title,
          taskType: task.type == TaskType.points
              ? 'points'
              : task.type == TaskType.yesNo
              ? 'yesno'
              : 'custom',
          maxPoints: task.type == TaskType.points ? task.maxPoints : null,
        );
  }

  void _clearAllDrafts() {
    setState(() {
      _taskPointsDraft.clear();
      _taskNotesDraft.clear();
      _taskTitleDraft.clear();
      _editedTaskIds.clear();
     
    });
  }

  Widget _buildLoadingCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 16),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 16),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.points:
        return Icons.stacked_line_chart;
      case TaskType.yesNo:
        return Icons.check_circle_outline;
      case TaskType.custom:
        return Icons.note_alt_outlined;
    }
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.points:
        return Colors.blue;
      case TaskType.yesNo:
        return Colors.green;
      case TaskType.custom:
        return Colors.orange;
    }
  }
}
