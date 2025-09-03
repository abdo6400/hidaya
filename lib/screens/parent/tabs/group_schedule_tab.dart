import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/task_result_model.dart';
import 'package:hidaya/models/task_model.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/providers/firebase_providers.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;

class GroupScheduleTab extends ConsumerStatefulWidget {
  const GroupScheduleTab({super.key});

  @override
  ConsumerState<GroupScheduleTab> createState() => _GroupScheduleTabState();
}

class _GroupScheduleTabState extends ConsumerState<GroupScheduleTab> {
  String? _selectedGroupId;
  DateTime _weekStart = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weekStart = _getStartOfWeek(DateTime.now());
  }

  static DateTime _getStartOfWeek(DateTime date) {
    // Dart's weekday: Monday = 1, ..., Saturday = 6, Sunday = 7
    int daysToSubtract = date.weekday == 6 ? 0 : (date.weekday % 7 + 1);
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: daysToSubtract));
  }

  DateTime _addDays(DateTime date, int days) => date.add(Duration(days: days));

  Future<List<ScheduleGroupModel>> _getAllGroupsForChildren(List<ChildModel> children, WidgetRef ref) async {
    final allGroups = <String, ScheduleGroupModel>{};
    for (final child in children) {
      final childGroups = await ref.read(firebaseServiceProvider).getScheduleGroupsByChild(child.id);
      for (final group in childGroups) {
        allGroups[group.id] = group;
      }
    }
    return allGroups.values.toList();
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    if (authState == null) {
      return const Center(child: Text('يرجى تسجيل الدخول'));
    }

    return Column(
      children: [
        // Group Selection
        _buildGroupSelection(authState.id),
        
        if (_selectedGroupId != null) ...[
          // Week Navigation
          _buildWeekNavigation(),
          
          // Schedule Table
          Expanded(
            child: _buildScheduleTable(),
          ),
        ] else ...[
          // No Group Selected
          Expanded(
            child: _buildNoGroupSelected(),
          ),
        ],
      ],
    );
  }

  Widget _buildGroupSelection(String parentId) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر مجموعة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final childrenAsync = ref.watch(childrenByParentProvider(parentId));
              
              return childrenAsync.when(
                data: (children) {
                  // Get unique groups from children using scheduleGroupsByChildProvider
                  final approvedChildren = children.where((child) => child.isApproved).toList();
                  
                  if (approvedChildren.isEmpty) {
                    return const Text('لا توجد أطفال معتمدين');
                  }

                  // Use a FutureBuilder to get groups for each child
                  return FutureBuilder<List<ScheduleGroupModel>>(
                    future: _getAllGroupsForChildren(approvedChildren, ref),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingIndicator();
                      }
                      
                      if (snapshot.hasError) {
                        return const Text('خطأ في تحميل المجموعات');
                      }
                      
                      final groupList = snapshot.data ?? [];
                      
                      if (groupList.isEmpty) {
                        return const Text('لا توجد مجموعات متاحة');
                      }

                      return DropdownButtonFormField<String>(
                        value: _selectedGroupId,
                        decoration: InputDecoration(
                          labelText: 'المجموعة',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('اختر مجموعة'),
                          ),
                          ...groupList.map((group) => DropdownMenuItem<String>(
                            value: group.id,
                            child: Text(group.name),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGroupId = value;
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const LoadingIndicator(),
                error: (error, stack) => app_error.AsyncErrorWidget(
                  error: error,
                  stackTrace: stack,
                  onRetry: () => ref.refresh(childrenByParentProvider(parentId)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _previousWeek,
              icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Text(
                '${_weekStart.toIso8601String().split('T')[0]} - ${_addDays(_weekStart, 6).toIso8601String().split('T')[0]}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _nextWeek,
              icon: Icon(Icons.arrow_forward, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    if (_selectedGroupId == null) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, child) {
        final childrenAsync = ref.watch(childrenInGroupProvider(_selectedGroupId!));
        final tasksAsync = ref.watch(tasksForGroupProvider(_selectedGroupId!));

        return childrenAsync.when(
          data: (children) {
            return tasksAsync.when(
              data: (tasks) {
                if (children.isEmpty) {
                  return const Center(
                    child: Text('لا يوجد أطفال في هذه المجموعة'),
                  );
                }

                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('لا توجد مهام لهذه المجموعة'),
                  );
                }

                // Create a mock group for now since we don't have the group details
                final mockGroup = ScheduleGroupModel(
                  id: _selectedGroupId!,
                  name: 'المجموعة المختارة',
                  categoryId: '',
                  sheikhId: '',
                  description: 'مجموعة مؤقتة',
                  days: [],
                  createdAt: DateTime.now(),
                );

                return _buildWeeklyTable(mockGroup, children, tasks);
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => app_error.AsyncErrorWidget(
                error: error,
                stackTrace: stack,
                onRetry: () => ref.refresh(tasksForGroupProvider(_selectedGroupId!)),
              ),
            );
          },
          loading: () => const LoadingIndicator(),
          error: (error, stack) => app_error.AsyncErrorWidget(
            error: error,
            stackTrace: stack,
            onRetry: () => ref.refresh(childrenInGroupProvider(_selectedGroupId!)),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyTable(ScheduleGroupModel group, List<ChildModel> children, List<TaskModel> tasks) {
    // Get group schedule days
    final scheduleDays = _getGroupScheduleDays(group);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Header row
            _buildTableHeader(scheduleDays, tasks),
            const SizedBox(height: 8),
            // Children rows
            ...children.map((child) => _buildChildRow(child, scheduleDays, tasks)),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getGroupScheduleDays(ScheduleGroupModel group) {
    // This should come from the group's schedule
    // For now, using a default schedule
    const arabicDays = [
      'السبت',
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ];

    // Filter only the days when the group meets
    // This should be based on the group's actual schedule
    final meetingDays = [0, 2, 4]; // Example: Saturday, Monday, Wednesday

    return meetingDays.map((dayIndex) {
      final date = _addDays(_weekStart, dayIndex);
      final dateStr = date.toIso8601String().split('T')[0];
      final dayName = arabicDays[dayIndex];
      return {
        'date': date,
        'day': dayName,
        'dateStr': dateStr,
        'dayIndex': dayIndex,
      };
    }).toList();
  }

  Widget _buildTableHeader(List<Map<String, dynamic>> scheduleDays, List<TaskModel> tasks) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Fixed child name column
          Container(
            width: 120,
            padding: const EdgeInsets.all(8),
            child: Text(
              'اسم الطفل',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Schedule days columns
          ...scheduleDays.map((day) => Container(
            width: 140,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  day['day'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _formatDate(day['date']),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildChildRow(ChildModel child, List<Map<String, dynamic>> scheduleDays, List<TaskModel> tasks) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Fixed child name column
          Container(
            width: 120,
            padding: const EdgeInsets.all(8),
            child: Text(
              child.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Schedule days columns
          ...scheduleDays.map((day) => Container(
            width: 140,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Center(
              child: _buildDayResult(child, day['dateStr'], tasks),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDayResult(ChildModel child, String dateStr, List<TaskModel> tasks) {
    return Consumer(
      builder: (context, ref, _) {
        final resultsAsync = ref.watch(taskResultsByChildProvider(child.id));
        
        return resultsAsync.when(
          data: (results) {
            // Filter results for this specific date
            final dayResults = results.where((result) => result.date == dateStr).toList();
            
            if (dayResults.isEmpty) {
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                ),
                child: const Icon(Icons.remove, color: Colors.grey, size: 18),
              );
            }

            // Show the first result (assuming one task per day for now)
            final result = dayResults.first;
            if (result != null) {
              return _buildResultCell(result);
            }
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[400]!, width: 2),
              ),
              child: const Icon(Icons.remove, color: Colors.grey, size: 18),
            );
          },
          loading: () => const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (error, stack) => const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildResultCell(TaskResultModel result) {
    switch (result.taskType) {
      case 'points':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getPointsColor(result.points).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getPointsColor(result.points).withOpacity(0.3),
            ),
          ),
          child: Text(
            '${result.points}',
            style: TextStyle(
              color: _getPointsColor(result.points),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
        
      case 'yesno':
        final isYes = result.points == 1;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isYes ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isYes ? 'نعم' : 'لا',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        );
        
      case 'custom':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '✓',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
        
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '?',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      }
    }

  Color _getPointsColor(int points) {
    if (points >= 90) return AppTheme.successColor;
    if (points >= 70) return AppTheme.warningColor;
    if (points >= 50) return AppTheme.infoColor;
    return AppTheme.errorColor;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  Widget _buildNoGroupSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_chart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'اختر مجموعة لعرض الجدول',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم باختيار مجموعة من القائمة أعلاه لعرض جدول المهام',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
