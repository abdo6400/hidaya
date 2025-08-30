import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/schedule_groups_controller.dart';
import '../../controllers/child_tasks_controller.dart';
import '../../models/schedule_group_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart' as app_error;
import 'group_detail_screen.dart';
import 'create_group_screen.dart';

class SheikhDashboardScreen extends ConsumerStatefulWidget {
  const SheikhDashboardScreen({super.key});

  @override
  ConsumerState<SheikhDashboardScreen> createState() =>
      _SheikhDashboardScreenState();
}

class _SheikhDashboardScreenState extends ConsumerState<SheikhDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider);
    if (user == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_getTabTitle(_currentIndex)),
            actions: [
              if (_currentIndex == 0) // Groups tab
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _navigateToCreateGroup(context),
                ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _GroupsTab(sheikhId: user.id),
              _ChildrenTab(sheikhId: user.id),
              _TasksTab(sheikhId: user.id),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.group),
                label: 'المجموعات',
              ),
              NavigationDestination(
                icon: Icon(Icons.child_care),
                label: 'الأطفال',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment),
                label: 'المهام',
              ),
            ],
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
          ),
        ),
      ),
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'مجموعات الجدول';
      case 1:
        return 'الأطفال';
      case 2:
        return 'إدارة المهام';
      default:
        return 'لوحة التحكم';
    }
  }

  void _navigateToCreateGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
  }
}

class _GroupsTab extends ConsumerWidget {
  final String sheikhId;

  const _GroupsTab({required this.sheikhId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsWithCount = ref.watch(
      scheduleGroupsWithCountControllerProvider(sheikhId),
    );

    return groupsWithCount.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) =>
          app_error.AppErrorWidget(message: error.toString()),
      data: (groupsData) {
        if (groupsData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مجموعات بعد',
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
              .read(
                scheduleGroupsWithCountControllerProvider(sheikhId).notifier,
              )
              .refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupsData.length,
            itemBuilder: (context, index) {
              final group = groupsData[index]['group'] as ScheduleGroupModel;
              final childrenCount = groupsData[index]['childrenCount'] as int;

              return _GroupCard(
                group: group,
                childrenCount: childrenCount,
                onTap: () => _navigateToGroupDetail(context, group),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToGroupDetail(BuildContext context, ScheduleGroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupDetailScreen(group: group)),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final ScheduleGroupModel group;
  final int childrenCount;
  final VoidCallback onTap;

  const _GroupCard({
    required this.group,
    required this.childrenCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 18,
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
                      color: group.isActive
                          ? Colors.green[100]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      group.isActive ? 'نشط' : 'غير نشط',
                      style: TextStyle(
                        fontSize: 12,
                        color: group.isActive
                            ? Colors.green[700]
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (group.description.isNotEmpty) ...[
                Text(
                  group.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      group.daysDisplay,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.child_care, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '$childrenCount طفل',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildrenTab extends ConsumerWidget {
  final String sheikhId;

  const _ChildrenTab({required this.sheikhId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This will be implemented to show all children assigned to this sheikh's groups
    return const Center(child: Text('قائمة الأطفال - سيتم تنفيذها قريباً'));
  }
}

class _TasksTab extends ConsumerWidget {
  final String sheikhId;

  const _TasksTab({required this.sheikhId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This will be implemented to show task management
    return const Center(child: Text('إدارة المهام - سيتم تنفيذها قريباً'));
  }
}
