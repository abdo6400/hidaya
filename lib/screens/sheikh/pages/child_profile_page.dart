import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/models/task_result_model.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/task_model.dart';
import 'package:hidaya/providers/firebase_providers.dart';
import 'package:hidaya/utils/app_theme.dart';

class ChildProfilePage extends ConsumerStatefulWidget {
  final String sheikhId;
  final ChildModel child;
  final String categoryId;
  const ChildProfilePage({
    super.key,
    required this.sheikhId,
    required this.child,
    required this.categoryId,
  });

  @override
  ConsumerState<ChildProfilePage> createState() => _ChildProfilePageState();
}

class _ChildProfilePageState extends ConsumerState<ChildProfilePage> {
  String? _selectedDate;
  String _searchQuery = '';
  String? _selectedTaskType;
  List<TaskResultModel> _allResults = [];
  List<TaskResultModel> _filteredResults = [];
  bool _isLoading = true;
  bool _isWeeklyView = true; // Toggle between weekly and list view
  late DateTime _weekStart;
  List<TaskModel> _weekTasks = [];

  @override
  void initState() {
    super.initState();
    _weekStart = _getStartOfWeek(DateTime.now());
    _loadResults();
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

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    try {
      final results = await ref
          .read(firebaseServiceProvider)
          .getTaskResultsByChild(widget.child.id);
      setState(() {
        _allResults = results;
        _filteredResults = results;
      });

      // Also load week tasks
      await _loadWeekTasks(widget.categoryId);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredResults = _allResults.where((result) {
        // Date filter
        if (_selectedDate != null && result.date != _selectedDate) {
          return false;
        }

        // Task type filter
        if (_selectedTaskType != null && result.taskType != _selectedTaskType) {
          return false;
        }

        // Title search filter
        if (_searchQuery.isNotEmpty) {
          final title = result.taskTitle?.toLowerCase() ?? '';
          if (!title.contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
    _loadWeekTasks(widget.categoryId);
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
    _loadWeekTasks(widget.categoryId);
  }

  Future<void> _loadWeekTasks(String categoryId) async {
    try {
      // Get all tasks for now, we can filter by category later
      final tasks = await ref
          .read(firebaseServiceProvider)
          .getTasksByCategory(categoryId);
      setState(() {
        _weekTasks = tasks.take(5).toList(); // Show first 5 tasks for demo
      });
    } catch (e) {
      // Handle error
    }
  }

  List<TaskModel> _getWeekTasks() {
    return _weekTasks.isNotEmpty ? _weekTasks : [];
  }

  List<Map<String, dynamic>> _getWeekDays() {
    const arabicDays = [
      'السبت',
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ];

    return List.generate(7, (i) {
      final date = _addDays(_weekStart, i);
      final dateStr = date.toIso8601String().split('T')[0];
      final dayIndex = i; // 0 to 6, starting from Saturday
      final dayName = arabicDays[dayIndex];
      return {'date': date, 'day': dayName, 'dateStr': dateStr};
    });
  }

  TaskResultModel? _getResultForDateAndTask(String date, String taskId) {
    return _allResults.firstWhere(
      (result) => result.date == date && result.taskId == taskId,
      orElse: () =>
          TaskResultModel(id: '', childId: '', taskId: '', points: 0, date: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ملف ${widget.child.name}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),

          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Column(
          children: [
            // View toggle and results count
            Card(
              child: Row(
                children: [
                  // View toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isWeeklyView = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _isWeeklyView
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'عرض أسبوعي',
                              style: TextStyle(
                                color: _isWeeklyView
                                    ? Colors.white
                                    : AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isWeeklyView = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: !_isWeeklyView
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'عرض قائمة',
                              style: TextStyle(
                                color: !_isWeeklyView
                                    ? Colors.white
                                    : AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Results count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_filteredResults.length} نتيجة',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (!_isWeeklyView) ...[
              _buildFilters(),
              const SizedBox(height: 10),
            ],
            Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search by task title
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث في عنوان المهمة...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.search,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Date filter
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedDate,
                    style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                    decoration: InputDecoration(
                      labelText: 'التاريخ',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('جميع التواريخ'),
                      ),
                      ...(() {
                        final dates = _allResults
                            .map((r) => r.date)
                            .toSet()
                            .toList();
                        dates.sort((a, b) => b.compareTo(a));
                        return dates;
                      })().map(
                        (date) => DropdownMenuItem(
                          value: date,
                          child: Text(_formatDate(date)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      _selectedDate = value;
                      _applyFilters();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Task type filter
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedTaskType,
                    style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                    decoration: InputDecoration(
                      labelText: 'نوع المهمة',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('جميع الأنواع'),
                      ),
                      const DropdownMenuItem(
                        value: 'points',
                        child: Text('نقاط'),
                      ),
                      const DropdownMenuItem(
                        value: 'yesno',
                        child: Text('نعم/لا'),
                      ),
                      const DropdownMenuItem(
                        value: 'custom',
                        child: Text('مخصص'),
                      ),
                    ],
                    onChanged: (value) {
                      _selectedTaskType = value;
                      _applyFilters();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isWeeklyView) {
      return _buildWeeklyView();
    } else {
      if (_filteredResults.isEmpty) {
        return _buildEmptyState();
      }
      return _buildTableView();
    }
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          headingRowColor: MaterialStateProperty.all(
            AppTheme.primaryColor.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(
              label: Text(
                'عنوان المهمة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'النتيجة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'ملاحظات',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: _filteredResults.map((result) {
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      result.taskTitle ?? 'بدون',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(_buildResultCell(result)),
                DataCell(
                  Container(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      result.notes ?? '-',
                      style: TextStyle(
                        color: result.notes?.isNotEmpty == true
                            ? Colors.grey[700]
                            : Colors.grey[400],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWeeklyView() {
    return Column(
      children: [
        // Week navigation
        Container(
          padding: const EdgeInsets.all(16),
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
        ),
        // Weekly table
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // Header row
                  Container(
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
                        // Fixed day column
                        Container(
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'اليوم',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        

                        // Tasks columns
                        ..._getWeekTasks().map(
                          (task) => Container(
                            width: 120,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              task.title,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Days rows
                  ..._getWeekDays().map((day) {
                    final dateStr = day['dateStr'] as String;
                    final isToday = day['date'] == DateTime.now();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isToday
                            ? Colors.green.withOpacity(0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isToday
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Fixed day column
                          Container(
                            width: 80,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '${day['day']}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isToday
                                        ? Colors.green
                                        : Colors.grey[700],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                            
                          // Tasks columns
                          ..._getWeekTasks().map((task) {
                            final result = _getResultForDateAndTask(
                              dateStr,
                              task.id,
                            );

                            return Container(
                              width: 120,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: _buildWeeklyResultCell(result, task),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCell(TaskResultModel result) {
    if (result.taskType == 'points') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${result.points}',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (result.maxPoints != null) ...[
            Text(
              ' / ${result.maxPoints}',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      );
    } else if (result.taskType == 'yesno') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: result.points == 1 ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          result.points == 1 ? 'نعم' : 'لا',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    } else {
      return Text(
        'مخصص',
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
      );
    }
  }

  Widget _buildWeeklyResultCell(TaskResultModel? result, TaskModel task) {
    if (result == null) {
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
    if (task.type == TaskType.points) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.2),
              AppTheme.primaryColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '${result.points}',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    } else if (task.type == TaskType.yesNo) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: result.points == 1
                ? [Colors.green[400]!, Colors.green[600]!]
                : [Colors.red[400]!, Colors.red[600]!],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (result.points == 1 ? Colors.green : Colors.red)
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          result.points == 1 ? 'نعم' : 'لا',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[400]!, Colors.orange[600]!],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'ملاحظة',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد نتائج',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'جرب تغيير الفلاتر أو إضافة نتائج جديدة',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }
}
