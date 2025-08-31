import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/category_controller.dart';
import 'package:hidaya/models/category_model.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/schedule_model.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/services/group_children_service.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/controllers/schedule_groups_controller.dart';
import 'package:hidaya/controllers/group_children_controller.dart';
import 'package:hidaya/controllers/sheikhs_controller.dart';
import 'assign_children_screen.dart';
import 'edit_group_screen.dart';

class AdminGroupDetailScreen extends ConsumerStatefulWidget {
  final ScheduleGroupModel group;

  const AdminGroupDetailScreen({super.key, required this.group});

  @override
  ConsumerState<AdminGroupDetailScreen> createState() => _AdminGroupDetailScreenState();
}

class _AdminGroupDetailScreenState extends ConsumerState<AdminGroupDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToAssignChildren() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AssignChildrenScreen(group: widget.group)),
    ).then((_) {
      // Refresh the children list when returning from the assign screen
      if (mounted) {
        ref.invalidate(groupChildrenControllerProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () => _editGroup())],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAssignChildren,
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          // Group Info Card
          _buildGroupInfoCard(),

          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'الأطفال'),
              Tab(text: 'المواعيد'),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ChildrenTab(group: widget.group),
                _ScheduleTab(group: widget.group),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.group.name, style: Theme.of(context).textTheme.headlineSmall),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.group.isActive ? Colors.green[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.group.isActive ? 'نشط' : 'غير نشط',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.group.isActive ? Colors.green[700] : Colors.grey[600],
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
                    final sheikhAsync = ref.watch(sheikhsControllerProvider);
                    return sheikhAsync.when(
                      loading: () => const Text('جاري التحميل...'),
                      error: (error, stack) => Text('خطأ: $error'),
                      data: (sheikhs) {
                        final sheikh = sheikhs.firstWhere(
                          (s) => s.id == widget.group.sheikhId,
                          orElse: () => AppUser(
                            id: '',
                            username: 'غير محدد',
                            role: UserRole.sheikh,
                            name: '',
                            email: '',
                            phone: '',
                            status: '',
                          ),
                        );
                        return Text(sheikh.username);
                      },
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
                    final categoriesAsync = ref.watch(categoryControllerProvider);
                    return categoriesAsync.when(
                      loading: () => const Text('جاري التحميل...'),
                      error: (error, stack) => const Text('خطأ في التحميل'),
                      data: (categories) {
                        final category = categories.firstWhere(
                          (cat) => cat.id == widget.group.categoryId,
                          orElse: () => CategoryModel(id: '', name: 'غير محدد', description: ''),
                        );
                        return Text(
                          'التصنيف: ${category.name}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

  Future<void> _editGroup() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => EditGroupScreen(group: widget.group)));

    if (result == true && mounted) {
      // Refresh the group data
      ref.invalidate(scheduleGroupsControllerProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث بيانات المجموعة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
  late final Future<List<ChildModel>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final groupChildrenService = GroupChildrenService();
      _childrenFuture = groupChildrenService.getChildrenInGroup(widget.group.id);
    } catch (e) {
      // Handle error
      debugPrint('Error loading children: $e');
      _childrenFuture = Future.value(<ChildModel>[]);
    }
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
                Icon(Icons.child_care_outlined, size: 64, color: Colors.grey[400]),
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
            return _ChildCard(
              child: child,
              group: widget.group,
              onRemoved: _loadChildren, // Refresh the list when a child is removed
            );
          },
        );
      },
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildModel child;
  final ScheduleGroupModel group;
  final VoidCallback? onRemoved;

  const _ChildCard({required this.child, required this.group, this.onRemoved});

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
              child: Row(children: [Icon(Icons.visibility), SizedBox(width: 8), Text('عرض الملف')]),
            ),
            const PopupMenuItem(
              value: 'tasks',
              child: Row(
                children: [Icon(Icons.assignment), SizedBox(width: 8), Text('عرض المهام')],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, color: Colors.red),
                  SizedBox(width: 8),
                  Text('إزالة من المجموعة', style: TextStyle(color: Colors.red)),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('عرض ملف الطفل - سيتم تنفيذها قريباً')));
        break;
      case 'tasks':
        // TODO: Navigate to child tasks screen
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('عرض مهام الطفل - سيتم تنفيذها قريباً')));
        break;
      case 'remove':
        _showRemoveChildDialog(context);
        break;
    }
  }

  Future<void> _removeChild(BuildContext context) async {
    try {
      final groupChildrenService = GroupChildrenService();
      await groupChildrenService.removeChildFromGroup(group.id, child.id);
      if (onRemoved != null) {
        onRemoved!();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إزالة الطفل من المجموعة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إزالة الطفل: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showRemoveChildDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إزالة من المجموعة'),
        content: Text('هل أنت متأكد من إزالة ${child.name} من المجموعة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeChild(context);
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


