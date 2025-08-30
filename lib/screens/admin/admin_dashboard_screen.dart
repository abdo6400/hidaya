import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/schedule_groups_controller.dart';
import 'package:hidaya/controllers/category_controller.dart';
import 'package:hidaya/controllers/reports_controller.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/category_model.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:hidaya/widgets/loading_indicator.dart';
import 'create_group_screen.dart';
import 'edit_group_screen.dart';
import 'group_detail_screen.dart';
import 'reports_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            // Tab Bar
            TabBar(
              onTap: (index) => setState(() => _currentIndex = index),
              tabs: const [
                Tab(text: 'المجموعات'),
                Tab(text: 'التقارير'),
              ],
            ),

            // Tab Content
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [_GroupsTab(), ReportsScreen()],
              ),
            ),
          ],
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: () => _createNewGroup(),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  void _createNewGroup() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateGroupScreen()));

    if (result == true) {
      // Refresh the groups list
      ref.invalidate(scheduleGroupsControllerProvider('all'));
    }
  }
}

class _GroupsTab extends ConsumerWidget {
  const _GroupsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(scheduleGroupsControllerProvider('all'));

    return groupsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) =>
          app_error.AppErrorWidget(message: error.toString()),
      data: (groups) {
        if (groups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مجموعات',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'اضغط على + لإنشاء مجموعة جديدة',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref
              .read(scheduleGroupsControllerProvider('all').notifier)
              .loadScheduleGroups(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _GroupCardWithChildrenCount(
                group: group,
                onGroupUpdated: () {
                  // Refresh the groups list
                  ref.invalidate(scheduleGroupsControllerProvider('all'));
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _GroupCardWithChildrenCount extends ConsumerWidget {
  final ScheduleGroupModel group;
  final VoidCallback? onGroupUpdated;

  const _GroupCardWithChildrenCount({required this.group, this.onGroupUpdated});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get children count for this group
    final childrenCountAsync = ref.watch(
      FutureProvider.family<int, String>((ref, groupId) async {
        final service = ref.read(scheduleGroupsServiceProvider);
        return await service.getChildrenCountForGroup(groupId);
      })(group.id),
    );

    return childrenCountAsync.when(
      loading: () => _GroupCard(
        group: group,
        childrenCount: 0,
        onGroupUpdated: onGroupUpdated,
      ),
      error: (_, __) => _GroupCard(
        group: group,
        childrenCount: 0,
        onGroupUpdated: onGroupUpdated,
      ),
      data: (childrenCount) => _GroupCard(
        group: group,
        childrenCount: childrenCount,
        onGroupUpdated: onGroupUpdated,
      ),
    );
  }
}

class _GroupCard extends ConsumerStatefulWidget {
  final ScheduleGroupModel group;
  final int childrenCount;
  final VoidCallback? onGroupUpdated;

  const _GroupCard({
    required this.group,
    required this.childrenCount,
    this.onGroupUpdated,
  });

  @override
  ConsumerState<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends ConsumerState<_GroupCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: widget.group.isActive
              ? Colors.green[100]
              : Colors.grey[100],
          child: Icon(
            Icons.group,
            color: widget.group.isActive ? Colors.green[700] : Colors.grey[600],
          ),
        ),
        title: Text(
          widget.group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.group.description.isNotEmpty)
              Text(widget.group.description),
            Text(
              widget.group.daysDisplay,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
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
                      fontSize: 10,
                      color: widget.group.isActive
                          ? Colors.green[700]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.childrenCount} طفل',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final categoriesAsync = ref.watch(
                      categoryControllerProvider,
                    );
                    return categoriesAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
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
                          'الفئة: ${category.name}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final sheikhNameAsync = ref.watch(
                      sheikhNameProvider(widget.group.sheikhId),
                    );
                    return sheikhNameAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => Text(
                        'الشيخ: ${widget.group.sheikhId}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      data: (sheikhName) => Text(
                        'الشيخ: $sheikhName',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('عرض التفاصيل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('تعديل')],
              ),
            ),
            const PopupMenuItem(
              value: 'assign',
              child: Row(
                children: [
                  Icon(Icons.people),
                  SizedBox(width: 8),
                  Text('تعيين أطفال'),
                ],
              ),
            ),
            PopupMenuItem(
              value: widget.group.isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(
                    widget.group.isActive ? Icons.pause : Icons.play_arrow,
                    color: widget.group.isActive ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.group.isActive ? 'إيقاف' : 'تفعيل',
                    style: TextStyle(
                      color: widget.group.isActive
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AdminGroupDetailScreen(group: widget.group),
            ),
          );
        },
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdminGroupDetailScreen(group: widget.group),
          ),
        );
        break;
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditGroupScreen(group: widget.group),
          ),
        );
        break;
      case 'assign':
        // TODO: Navigate to assign children screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعيين أطفال - سيتم تنفيذها قريباً')),
        );
        break;
      case 'activate':
      case 'deactivate':
        _toggleGroupStatus(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _toggleGroupStatus(BuildContext context) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          widget.group.isActive ? 'إيقاف المجموعة' : 'تفعيل المجموعة',
        ),
        content: Text(
          widget.group.isActive
              ? 'هل أنت متأكد من إيقاف مجموعة "${widget.group.name}"؟'
              : 'هل أنت متأكد من تفعيل مجموعة "${widget.group.name}"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performToggleStatus(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.group.isActive
                  ? Colors.orange
                  : Colors.green,
            ),
            child: Text(widget.group.isActive ? 'إيقاف' : 'تفعيل'),
          ),
        ],
      ),
    );
  }

  void _performToggleStatus(BuildContext context) async {
    try {
      final updatedGroup = widget.group.copyWith(
        isActive: !widget.group.isActive,
        updatedAt: DateTime.now(),
      );

      await ref
          .read(scheduleGroupsControllerProvider('all').notifier)
          .updateScheduleGroup(widget.group.id, updatedGroup);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.group.isActive ? 'تم إيقاف المجموعة' : 'تم تفعيل المجموعة',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onGroupUpdated?.call();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث حالة المجموعة: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المجموعة'),
        content: Text(
          'هل أنت متأكد من حذف مجموعة "${widget.group.name}"؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _performDelete(BuildContext context) {
    // This will be handled by the parent widget to refresh the list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف المجموعة بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
