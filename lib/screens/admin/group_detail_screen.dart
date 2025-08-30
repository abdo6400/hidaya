import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/child_tasks_controller.dart';
import 'package:hidaya/controllers/category_controller.dart';
import 'package:hidaya/controllers/reports_controller.dart';
import 'package:hidaya/models/category_model.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/schedule_model.dart';
import 'package:hidaya/services/group_children_service.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:hidaya/widgets/loading_indicator.dart';
import 'assign_children_screen.dart';

class AdminGroupDetailScreen extends ConsumerStatefulWidget {
  final ScheduleGroupModel group;

  const AdminGroupDetailScreen({super.key, required this.group});

  @override
  ConsumerState<AdminGroupDetailScreen> createState() =>
      _AdminGroupDetailScreenState();
}

class _AdminGroupDetailScreenState extends ConsumerState<AdminGroupDetailScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editGroup(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group Info Card
          _buildGroupInfoCard(),

          // Tab Bar
          TabBar(
            controller: TabController(
              length: 3,
              vsync: this,
              initialIndex: _currentIndex,
            ),
            onTap: (index) => setState(() => _currentIndex = index),
            tabs: const [
              Tab(text: 'الأطفال'),
              Tab(text: 'المواعيد'),
              Tab(text: 'التقدم'),
            ],
          ),

          // Tab Content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _ChildrenTab(group: widget.group),
                _ScheduleTab(group: widget.group),
                _ProgressTab(group: widget.group),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _addChildToGroup(),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Widget _buildGroupInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.group.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.group.isActive
                        ? Colors.green[100]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.group.isActive ? 'نشط' : 'غير نشط',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.group.isActive
                          ? Colors.green[700]
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            if (widget.group.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.group.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.group.daysDisplay,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Consumer(
                  builder: (context, ref, child) {
                    final sheikhNameAsync = ref.watch(
                      sheikhNameProvider(widget.group.sheikhId),
                    );
                    return sheikhNameAsync.when(
                      loading: () => const Text('جاري التحميل...'),
                      error: (_, __) => Text(
                        'الشيخ: ${widget.group.sheikhId}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      data: (sheikhName) => Text(
                        'الشيخ: $sheikhName',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Consumer(
                  builder: (context, ref, child) {
                    final categoriesAsync = ref.watch(
                      categoryControllerProvider,
                    );
                    return categoriesAsync.when(
                      loading: () => const Text('جاري التحميل...'),
                      error: (error, stack) => const Text('خطأ في التحميل'),
                      data: (categories) {
                        final category = categories.firstWhere(
                          (cat) => cat.id == widget.group.categoryId,
                          orElse: () => CategoryModel(
                            id: '',
                            name: 'غير محدد',
                            description: '',
                          ),
                        );
                        return Text(
                          'التصنيف: ${category.name}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editGroup() {
    // TODO: Navigate to edit group screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تعديل المجموعة - سيتم تنفيذها قريباً')),
    );
  }

  void _addChildToGroup() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AssignChildrenScreen(group: widget.group),
      ),
    );

    if (result == true) {
      // Refresh the children tab
      setState(() {
        // This will trigger a rebuild of the children tab
      });
    }
  }
}

class _ChildrenTab extends ConsumerStatefulWidget {
  final ScheduleGroupModel group;

  const _ChildrenTab({required this.group});

  @override
  ConsumerState<_ChildrenTab> createState() => _ChildrenTabState();
}

class _ChildrenTabState extends ConsumerState<_ChildrenTab> {
  final GroupChildrenService _groupChildrenService = GroupChildrenService();
  late Future<List<ChildModel>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    _childrenFuture = _groupChildrenService.getChildrenInGroup(widget.group.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChildModel>>(
      future: _childrenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return app_error.AppErrorWidget(message: snapshot.error.toString());
        }

        final children = snapshot.data ?? [];

        if (children.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.child_care_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد أطفال في هذه المجموعة',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'اضغط على + لإضافة طفل',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
            return _ChildCard(child: child, group: widget.group);
          },
        );
      },
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildModel child;
  final ScheduleGroupModel group;

  const _ChildCard({required this.child, required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            child.name.substring(0, 1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(child.name),
        subtitle: Text('العمر: ${child.age}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('عرض الملف'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'tasks',
              child: Row(
                children: [
                  Icon(Icons.assignment),
                  SizedBox(width: 8),
                  Text('عرض المهام'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'إزالة من المجموعة',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        // TODO: Navigate to child profile screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عرض ملف الطفل - سيتم تنفيذها قريباً')),
        );
        break;
      case 'tasks':
        // TODO: Navigate to child tasks screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عرض مهام الطفل - سيتم تنفيذها قريباً')),
        );
        break;
      case 'remove':
        _showRemoveChildDialog(context);
        break;
    }
  }

  void _showRemoveChildDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إزالة من المجموعة'),
        content: Text('هل أنت متأكد من إزالة ${child.name} من المجموعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Remove child from group
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('إزالة الطفل - سيتم تنفيذها قريباً'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  final ScheduleGroupModel group;

  const _ScheduleTab({required this.group});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: group.days.length,
      itemBuilder: (context, index) {
        final daySchedule = group.days[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(_getDayName(daySchedule.day)),
            children: daySchedule.timeSlots.map((slot) {
              return ListTile(
                leading: const Icon(Icons.access_time),
                title: Text('${slot.startTime} - ${slot.endTime}'),
                subtitle: Text('التصنيف: ${slot.categoryId}'),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getDayName(WeekDay day) {
    switch (day) {
      case WeekDay.sunday:
        return 'الأحد';
      case WeekDay.monday:
        return 'الاثنين';
      case WeekDay.tuesday:
        return 'الثلاثاء';
      case WeekDay.wednesday:
        return 'الأربعاء';
      case WeekDay.thursday:
        return 'الخميس';
      case WeekDay.friday:
        return 'الجمعة';
      case WeekDay.saturday:
        return 'السبت';
    }
  }
}

class _ProgressTab extends ConsumerWidget {
  final ScheduleGroupModel group;

  const _ProgressTab({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupProgress = ref.watch(groupProgressControllerProvider(group.id));

    return groupProgress.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) =>
          app_error.AppErrorWidget(message: error.toString()),
      data: (progress) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress Cards
              Row(
                children: [
                  Expanded(
                    child: _ProgressCard(
                      title: 'إجمالي المهام',
                      value: progress['totalTasks'].toString(),
                      icon: Icons.assignment,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProgressCard(
                      title: 'المهام المكتملة',
                      value: progress['completedTasks'].toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ProgressCard(
                      title: 'نسبة الإنجاز',
                      value:
                          '${progress['completionRate'].toStringAsFixed(1)}%',
                      icon: Icons.trending_up,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProgressCard(
                      title: 'متوسط الدرجات',
                      value: progress['averageMark'].toStringAsFixed(1),
                      icon: Icons.grade,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ranking
              const Text(
                'ترتيب الأطفال',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildRankingList(ref)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankingList(WidgetRef ref) {
    final ranking = ref.watch(childRankingControllerProvider(group.id));

    return ranking.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) =>
          app_error.AppErrorWidget(message: error.toString()),
      data: (rankingList) {
        if (rankingList.isEmpty) {
          return const Center(child: Text('لا توجد بيانات للترتيب'));
        }

        return ListView.builder(
          itemCount: rankingList.length,
          itemBuilder: (context, index) {
            final rank = rankingList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(rank['rank'] as int),
                  child: Text(
                    rank['rank'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text('الطفل ${rank['childId']}'), // TODO: Get child name
                subtitle: Text('النقاط: ${rank['score'].toStringAsFixed(1)}'),
                trailing: Text(
                  '${rank['completedTasks']} مهام مكتملة',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.blue;
    }
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
