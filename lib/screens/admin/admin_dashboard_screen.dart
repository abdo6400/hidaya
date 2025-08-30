import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/schedule_groups_controller.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:hidaya/widgets/loading_indicator.dart';
import 'create_group_screen.dart';
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
      setState(() {});
    }
  }
}

class _GroupsTab extends ConsumerWidget {
  const _GroupsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(scheduleGroupsControllerProvider('admin'));

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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return _GroupCard(group: group);
          },
        );
      },
    );
  }
}

class _GroupCard extends ConsumerWidget {
  final ScheduleGroupModel group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: group.isActive
              ? Colors.green[100]
              : Colors.grey[100],
          child: Icon(
            Icons.group,
            color: group.isActive ? Colors.green[700] : Colors.grey[600],
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.description.isNotEmpty) Text(group.description),
            Text(
              group.daysDisplay,
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
                    color: group.isActive
                        ? Colors.green[100]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group.isActive ? 'نشط' : 'غير نشط',
                    style: TextStyle(
                      fontSize: 10,
                      color: group.isActive
                          ? Colors.green[700]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'الشيخ: ${group.sheikhId}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
              value: group.isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(
                    group.isActive ? Icons.pause : Icons.play_arrow,
                    color: group.isActive ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    group.isActive ? 'إيقاف' : 'تفعيل',
                    style: TextStyle(
                      color: group.isActive ? Colors.orange : Colors.green,
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
              builder: (context) => AdminGroupDetailScreen(group: group),
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
            builder: (context) => AdminGroupDetailScreen(group: group),
          ),
        );
        break;
      case 'edit':
        // TODO: Navigate to edit group screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعديل المجموعة - سيتم تنفيذها قريباً')),
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
    // TODO: Implement group status toggle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          group.isActive ? 'تم إيقاف المجموعة' : 'تم تفعيل المجموعة',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المجموعة'),
        content: Text('هل أنت متأكد من حذف مجموعة "${group.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('حذف المجموعة - سيتم تنفيذها قريباً'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
