import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/task_result_model.dart';

import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/providers/firebase_providers.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;

class ChildProfilePage extends ConsumerStatefulWidget {
  final ChildModel child;

  const ChildProfilePage({super.key, required this.child});

  @override
  ConsumerState<ChildProfilePage> createState() => _ChildProfilePageState();
}

class _ChildProfilePageState extends ConsumerState<ChildProfilePage> {
  String _searchQuery = '';
  String _selectedGroupId = '';
  DateTime? _selectedDate;
  String? _selectedTaskType;
  String _sortBy = 'date';
  bool _sortAscending = false;
  int _currentViewIndex = 0; // 0: List View, 1: Daily Table View

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('${widget.child.name}'), elevation: 0),
        body: Column(
          children: [
            // Filters Section
            _buildFiltersSection(),
            // Content based on selected view
            Expanded(child: _buildDailyResultsTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
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
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'البحث في المهام...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 10),
          _buildGroupFilter(),
          const SizedBox(height: 10),
          _buildDateFilter(),
        ],
      ),
    );
  }

  Widget _buildGroupFilter() {
    return Consumer(
      builder: (context, ref, child) {
        final groupsAsync = ref.watch(
          scheduleGroupsByChildProvider(widget.child.id),
        );

        return groupsAsync.when(
          data: (groups) {
            if (groups.isEmpty) {
              return Container(
                height: 56,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('لا توجد مجموعات مسجلة')),
              );
            }

            return DropdownButtonFormField<String>(
              value: _selectedGroupId.isEmpty ? null : _selectedGroupId,
              decoration: InputDecoration(
                labelText: 'المجموعة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('جميع المجموعات'),
                ),
                ...groups.map(
                  (group) => DropdownMenuItem<String>(
                    value: group.id,
                    child: Text(group.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGroupId = value ?? '';
                });
              },
            );
          },
          loading: () => const SizedBox(
            height: 56,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => const SizedBox(
            height: 56,
            child: Center(child: Text('خطأ في تحميل المجموعات')),
          ),
        );
      },
    );
  }

  Widget _buildDateFilter() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'جميع التواريخ',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (_selectedDate != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                  });
                },
                icon: const Icon(Icons.clear, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  List<TaskResultModel> _filterAndSortResults(List<TaskResultModel> results) {
    var filtered = results.where((result) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final taskTitle = result.taskTitle?.toLowerCase() ?? '';
        if (!taskTitle.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Group filter
      if (_selectedGroupId.isNotEmpty) {
        if (result.groupId != _selectedGroupId) {
          return false;
        }
      }

      // Date filter
      if (_selectedDate != null) {
        final resultDate = result.submittedAt;
        if (resultDate == null ||
            resultDate.year != _selectedDate!.year ||
            resultDate.month != _selectedDate!.month ||
            resultDate.day != _selectedDate!.day) {
          return false;
        }
      }

      // Task type filter
      if (_selectedTaskType != null && result.taskType != _selectedTaskType) {
        return false;
      }

      return true;
    }).toList();

    // Sort results
    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'date':
          final aDate = a.submittedAt ?? DateTime(1970);
          final bDate = b.submittedAt ?? DateTime(1970);
          comparison = aDate.compareTo(bDate);
          break;
        case 'points':
          comparison = a.points.compareTo(b.points);
          break;
        case 'task':
          final aTitle = a.taskTitle ?? '';
          final bTitle = b.taskTitle ?? '';
          comparison = aTitle.compareTo(bTitle);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  Widget _buildDailyResultsTable() {
    return Consumer(
      builder: (context, ref, child) {
        final resultsAsync = ref.watch(
          taskResultsByChildProvider(widget.child.id),
        );

        return resultsAsync.when(
          data: (results) {
            final filteredResults = _filterAndSortResults(results);
            final dailyResults = _groupResultsByDay(filteredResults);

            if (dailyResults.isEmpty) {
              return const Center(child: Text('لا توجد نتائج لعرضها'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Table Header
                  _buildTableHeader(),
                  const SizedBox(height: 8),
                  // Daily Rows
                  ...dailyResults.entries.map(
                    (entry) => _buildDailyRow(entry.key, entry.value),
                  ),
                ],
              ),
            );
          },
          loading: () => const LoadingIndicator(),
          error: (error, stack) => app_error.AsyncErrorWidget(
            error: error,
            stackTrace: stack,
            onRetry: () =>
                ref.refresh(taskResultsByChildProvider(widget.child.id)),
          ),
        );
      },
    );
  }

  Map<String, List<TaskResultModel>> _groupResultsByDay(
    List<TaskResultModel> results,
  ) {
    final dailyResults = <String, List<TaskResultModel>>{};

    for (final result in results) {
      if (result.submittedAt != null) {
        final dateKey = _formatDateForTable(result.submittedAt!);
        dailyResults.putIfAbsent(dateKey, () => []).add(result);
      }
    }

    // Sort days in descending order (most recent first)
    final sortedDays = dailyResults.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final sortedDailyResults = <String, List<TaskResultModel>>{};
    for (final day in sortedDays) {
      sortedDailyResults[day] = dailyResults[day]!;
    }

    return sortedDailyResults;
  }

  String _formatDateForTable(DateTime date) {
    const arabicDays = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    final dayName = arabicDays[date.weekday % 7];
    final dateStr = '${date.day}/${date.month}/${date.year}';

    return '$dayName - $dateStr';
  }

  Widget _buildTableHeader() {
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
          // Date column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                'التاريخ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Task column
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'المهمة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Result column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'النتيجة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRow(String dateKey, List<TaskResultModel> dayResults) {
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
      child: Column(
        children: [
          // Date header row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              dateKey,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Task results for this day
          ...dayResults.map((result) => _buildTaskResultRow(result)),
        ],
      ),
    );
  }

  Widget _buildTaskResultRow(TaskResultModel result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          // Task title
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.taskTitle ?? 'مهمة غير محددة',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Result display
          Expanded(child: _buildResultDisplay(result)),
        ],
      ),
    );
  }

  Widget _buildResultDisplay(TaskResultModel result) {
    switch (result.taskType) {
      case 'points':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getPointsColor(result.points).withOpacity(0.2),
                _getPointsColor(result.points).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getPointsColor(result.points).withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getPointsColor(result.points).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars,
                color: _getPointsColor(result.points),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '${result.points}',
                style: TextStyle(
                  color: _getPointsColor(result.points),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (result.maxPoints != null) ...[
                Text(
                  ' / ${result.maxPoints}',
                  style: TextStyle(
                    color: _getPointsColor(result.points).withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        );

      case 'yesno':
        final isYes = result.points == 2;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isYes
                  ? [Colors.green[400]!, Colors.green[600]!]
                  : [Colors.red[400]!, Colors.red[600]!],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isYes ? Colors.green : Colors.red).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isYes ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isYes ? 'نعم' : 'لا',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );

      case 'custom':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[400]!, Colors.orange[600]!],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.notes ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.help_outline, color: Colors.grey[600], size: 18),
              const SizedBox(width: 6),
              Text(
                'غير محدد',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
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
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
