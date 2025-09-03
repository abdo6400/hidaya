import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/task_result_model.dart';
import 'package:hidaya/providers/firebase_providers.dart';
import 'package:hidaya/utils/app_theme.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String? _selectedGroupId;
  DateTimeRange? _selectedDateRange;
  DateTime? _selectedDate;
  String _dateFilterType = 'all'; // 'all', 'day', 'range', 'week', 'month'
  String _sortBy = 'points'; // 'name', 'points', 'group'
  bool _sortAscending = false; // false = descending (higher points first)
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التقارير'), elevation: 0),
        body: Column(
          children: [
            _buildFiltersSection(),
            Expanded(child: _buildReportsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          _buildDateFilter(),
          const SizedBox(height: 10),
          _buildGroupFilter(),
          const SizedBox(height: 10),
          // Filters Row
          Row(
            children: [
              // Date Filter
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'البحث عن طالب...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
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
      builder: (context, ref, _) {
        final groupsAsync = ref.watch(allScheduleGroupsProvider);
        return groupsAsync.when(
          loading: () => Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, st) => Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'خطأ في التحميل',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
          data: (groups) {
            final allGroups = [
              ScheduleGroupModel(
                id: 'all',
                sheikhId: '',
                categoryId: '',
                name: 'جميع المجموعات',
                description: '',
                days: [],
                isActive: true,
                createdAt: DateTime.now(),
              ),
              ...groups,
            ];

            return DropdownButtonFormField<String>(
              value: _selectedGroupId ?? 'all',
              decoration: InputDecoration(
                labelText: 'المجموعة',
                prefixIcon: const Icon(Icons.groups, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: allGroups.map((group) {
                return DropdownMenuItem<String>(
                  value: group.id,
                  child: Text(
                    group.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGroupId = value == 'all' ? null : value;
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDateFilter() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange:
                    _selectedDateRange ??
                    DateTimeRange(
                      start: DateTime.now().subtract(const Duration(days: 7)),
                      end: DateTime.now(),
                    ),
              );
              if (picked != null) {
                setState(() {
                  _dateFilterType = 'range';
                  _selectedDateRange = picked;
                  _selectedDate = null; // clear single day
                });
              }
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dateFilterType == 'range' && _selectedDateRange != null
                          ? "${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}"
                          : _dateFilterType == 'week'
                          ? "هذا الأسبوع"
                          : _dateFilterType == 'month'
                          ? "هذا الشهر"
                          : _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'جميع التواريخ',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  if (_dateFilterType != 'all')
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _dateFilterType = 'all';
                          _selectedDateRange = null;
                          _selectedDate = null;
                        });
                      },
                      child: const Icon(
                        Icons.clear,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              _dateFilterType = value;
              if (value == 'week') {
                final now = DateTime.now();
                final startOfWeek = now.subtract(
                  Duration(days: now.weekday - 1),
                );
                _selectedDateRange = DateTimeRange(
                  start: startOfWeek,
                  end: now,
                );
              } else if (value == 'month') {
                final now = DateTime.now();
                final startOfMonth = DateTime(now.year, now.month, 1);
                _selectedDateRange = DateTimeRange(
                  start: startOfMonth,
                  end: now,
                );
              } else {
                _selectedDateRange = null;
              }
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'week', child: Text('هذا الأسبوع')),
            const PopupMenuItem(value: 'month', child: Text('هذا الشهر')),
          ],
          child: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          if (_sortBy == value) {
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = value;
            // Default sorting: points descending (high to low), others ascending
            _sortAscending = value != 'points';
          }
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'name',
          child: Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: _sortBy == 'name' ? AppTheme.primaryColor : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'الاسم',
                style: TextStyle(
                  color: _sortBy == 'name'
                      ? AppTheme.primaryColor
                      : Colors.black,
                  fontWeight: _sortBy == 'name'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (_sortBy == 'name')
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'points',
          child: Row(
            children: [
              Icon(
                Icons.stars,
                size: 16,
                color: _sortBy == 'points'
                    ? AppTheme.primaryColor
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'النقاط (الأعلى أولاً)',
                style: TextStyle(
                  color: _sortBy == 'points'
                      ? AppTheme.primaryColor
                      : Colors.black,
                  fontWeight: _sortBy == 'points'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (_sortBy == 'points')
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'group',
          child: Row(
            children: [
              Icon(
                Icons.groups,
                size: 16,
                color: _sortBy == 'group' ? AppTheme.primaryColor : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'المجموعة',
                style: TextStyle(
                  color: _sortBy == 'group'
                      ? AppTheme.primaryColor
                      : Colors.black,
                  fontWeight: _sortBy == 'group'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (_sortBy == 'group')
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
        ),
      ],
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.sort, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildReportsList() {
    return FutureBuilder<List<ChildWithPoints>>(
      future: _getChildrenWithPoints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ في تحميل البيانات',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.red[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final childrenWithPoints = snapshot.data ?? [];

        if (childrenWithPoints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد بيانات',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'لا توجد نتائج تطابق المعايير المحددة',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: childrenWithPoints.length,
          itemBuilder: (context, index) {
            final childWithPoints = childrenWithPoints[index];
            return _buildChildCard(childWithPoints, index);
          },
        );
      },
    );
  }

  Widget _buildChildCard(ChildWithPoints childWithPoints, int index) {
    final child = childWithPoints.child;
    final totalPoints = childWithPoints.totalPoints;
    final groupName = childWithPoints.groupName;

    // Get special colors for top 3
    Color? specialColor;
    IconData? specialIcon;

    if (index == 0) {
      // Gold for 1st place
      specialColor = const Color(0xFFFFD700);
      specialIcon = Icons.emoji_events;
    } else if (index == 1) {
      // Silver for 2nd place
      specialColor = const Color(0xFFC0C0C0);
      specialIcon = Icons.emoji_events;
    } else if (index == 2) {
      // Bronze for 3rd place
      specialColor = const Color(0xFFCD7F32);
      specialIcon = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: specialColor != null
            ? specialColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: specialColor != null
            ? Border.all(color: specialColor.withOpacity(0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: specialColor != null
                ? specialColor.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar with special styling for top 3
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: specialColor != null
                    ? specialColor.withOpacity(0.2)
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: specialColor != null
                    ? Border.all(color: specialColor, width: 2)
                    : null,
              ),
              child: Center(
                child: specialIcon != null && index < 3
                    ? Icon(specialIcon, color: specialColor, size: 24)
                    : Text(
                        child.name[0].toUpperCase(),
                        style: TextStyle(
                          color: specialColor ?? AppTheme.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Child Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        child.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: specialColor,
                            ),
                      ),
                      if (index < 3) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: specialColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (groupName.isNotEmpty)
                    Text(
                      groupName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: specialColor ?? AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            // Points Display with special styling for top 3
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: specialColor != null
                    ? specialColor.withOpacity(0.2)
                    : _getPointsColor(totalPoints).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: specialColor != null
                      ? specialColor
                      : _getPointsColor(totalPoints).withOpacity(0.3),
                  width: specialColor != null ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.stars,
                    color: specialColor ?? _getPointsColor(totalPoints),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalPoints',
                    style: TextStyle(
                      color: specialColor ?? _getPointsColor(totalPoints),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPointsColor(int points) {
    if (points >= 100) return Colors.green;
    if (points >= 50) return Colors.orange;
    if (points >= 20) return Colors.blue;
    return Colors.grey;
  }

  Future<void> _selectDate() async {
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
  }

  Future<List<ChildWithPoints>> _getChildrenWithPoints() async {
    final firebaseService = ref.read(firebaseServiceProvider);

    // Get all children
    List<ChildModel> children;
    if (_selectedGroupId != null) {
      children = await firebaseService.getChildrenInGroup(_selectedGroupId!);
    } else {
      children = await firebaseService.getAllChildren();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      children = children.where((child) {
        return child.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            child.id.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Get points for each child
    List<ChildWithPoints> childrenWithPoints = [];

    for (final child in children) {
      int totalPoints = 0;
      String groupName = '';

      // Get child's group
      final groups = await firebaseService.getScheduleGroupsByChild(child.id);
      if (groups.isNotEmpty) {
        groupName = groups.first.name;
      }

      // Get task results for the child
      final results = await firebaseService.getTaskResultsByChild(child.id);

      // Filter by date if selected
      List<TaskResultModel> filteredResults = results;

      if (_dateFilterType == 'day' && _selectedDate != null) {
        final selectedDateStr = _selectedDate!.toIso8601String().substring(
          0,
          10,
        );
        filteredResults = results
            .where((result) => result.date == selectedDateStr)
            .toList();
      } else if ((_dateFilterType == 'range' ||
              _dateFilterType == 'week' ||
              _dateFilterType == 'month') &&
          _selectedDateRange != null) {
        filteredResults = results.where((result) {
          final resultDate = DateTime.parse(result.date);
          return resultDate.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              resultDate.isBefore(
                _selectedDateRange!.end.add(const Duration(days: 1)),
              );
        }).toList();
      }

      // Calculate total points
      totalPoints = filteredResults.fold(
        0,
        (sum, result) => sum + result.points,
      );

      childrenWithPoints.add(
        ChildWithPoints(
          child: child,
          totalPoints: totalPoints,
          groupName: groupName,
        ),
      );
    }

    // Sort the results
    childrenWithPoints.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.child.name.compareTo(b.child.name);
          break;
        case 'points':
          comparison = a.totalPoints.compareTo(b.totalPoints);
          break;
        case 'group':
          comparison = a.groupName.compareTo(b.groupName);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return childrenWithPoints;
  }
}

class ChildWithPoints {
  final ChildModel child;
  final int totalPoints;
  final String groupName;

  ChildWithPoints({
    required this.child,
    required this.totalPoints,
    required this.groupName,
  });
}
