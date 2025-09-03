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
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('ملف ${widget.child.name}'),
          elevation: 0,
        ),
        body: Column(
          children: [
            // Child Info Header
            _buildChildHeader(),
            
            // Filters Section
            _buildFiltersSection(),
            
            // Task Results List
            Expanded(
              child: _buildTaskResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                widget.child.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.child.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'العمر: ${widget.child.age} سنة',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      widget.child.isApproved ? Icons.check_circle : Icons.pending,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.child.isApproved ? 'معتمد' : 'في انتظار الاعتماد',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          const SizedBox(height: 16),
          
          // Filters Row
          Row(
            children: [
              // Group Filter
              Expanded(
                child: _buildGroupFilter(),
              ),
              const SizedBox(width: 12),
              
              // Date Filter
              Expanded(
                child: _buildDateFilter(),
              ),
              const SizedBox(width: 12),
              
              // Sort Button
              _buildSortButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupFilter() {
    return Consumer(
      builder: (context, ref, child) {
        final groupsAsync = ref.watch(allScheduleGroupsProvider);
        
        return groupsAsync.when(
          data: (groups) {
            return DropdownButtonFormField<String>(
              value: _selectedGroupId.isEmpty ? null : _selectedGroupId,
              decoration: InputDecoration(
                labelText: 'المجموعة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('جميع المجموعات'),
                ),
                ...groups.map((group) => DropdownMenuItem<String>(
                  value: group.id,
                  child: Text(group.name),
                )),
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

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _sortBy = value;
          _sortAscending = value != 'date'; // Date defaults to descending, others to ascending
        });
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'date',
          child: Text('التاريخ'),
        ),
        const PopupMenuItem(
          value: 'points',
          child: Text('النقاط (الأعلى أولاً)'),
        ),
        const PopupMenuItem(
          value: 'task',
          child: Text('اسم المهمة'),
        ),
      ],
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 20),
            const SizedBox(width: 8),
            Text(_getSortLabel()),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'date':
        return 'التاريخ';
      case 'points':
        return 'النقاط';
      case 'task':
        return 'المهمة';
      default:
        return 'ترتيب';
    }
  }

  Widget _buildTaskResultsList() {
    return Consumer(
      builder: (context, ref, child) {
        final taskResultsAsync = ref.watch(
          taskResultsByChildProvider(widget.child.id),
        );

        return taskResultsAsync.when(
          data: (taskResults) {
            final filteredResults = _filterAndSortResults(taskResults);
            
            if (filteredResults.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد نتائج مهام',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لم يتم تسجيل أي نتائج مهام بعد',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredResults.length,
              itemBuilder: (context, index) {
                final result = filteredResults[index];
                return _buildTaskResultCard(result);
              },
            );
          },
          loading: () => const LoadingIndicator(),
          error: (error, stack) => app_error.AsyncErrorWidget(
            error: error,
            stackTrace: stack,
            onRetry: () => ref.refresh(
              taskResultsByChildProvider(widget.child.id),
            ),
          ),
        );
      },
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

  Widget _buildTaskResultCard(TaskResultModel result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.taskTitle ?? 'مهمة غير محددة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPointsColor(result.points).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getPointsColor(result.points).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars,
                        color: _getPointsColor(result.points),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${result.points}',
                        style: TextStyle(
                          color: _getPointsColor(result.points),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Task Details
            if (result.notes?.isNotEmpty == true) ...[
              Text(
                'ملاحظات: ${result.notes}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Footer Row
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  result.submittedAt != null 
                    ? _formatDate(result.submittedAt!)
                    : 'غير محدد',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  result.submittedAt != null 
                    ? _formatTime(result.submittedAt!)
                    : 'غير محدد',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
