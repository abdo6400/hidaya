import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/child_tasks_controller.dart';
import 'package:hidaya/controllers/group_children_controller.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/child_tasks_model.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:hidaya/widgets/loading_indicator.dart';

class ChildProfileScreen extends ConsumerStatefulWidget {
  final ChildModel child;

  const ChildProfileScreen({super.key, required this.child});

  @override
  ConsumerState<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends ConsumerState<ChildProfileScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ملف ${widget.child.name}'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المعلومات'),
            Tab(text: 'المهام'),
            Tab(text: 'التقدم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InfoTab(child: widget.child),
          _TasksTab(child: widget.child),
          _ProgressTab(child: widget.child),
        ],
      ),
    );
  }
}

class _InfoTab extends ConsumerWidget {
  final ChildModel child;

  const _InfoTab({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      child.name.substring(0, 1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    child.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'العمر: ${child.age} سنوات',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _InfoItem(
                        icon: Icons.check_circle,
                        label: 'الحالة',
                        value: child.isApproved ? 'موافق عليه' : 'في الانتظار',
                        color: child.isApproved ? Colors.green : Colors.orange,
                      ),
                      _InfoItem(
                        icon: Icons.calendar_today,
                        label: 'تاريخ التسجيل',
                        value:
                            child.createdAt?.toString().split(' ')[0] ??
                            'غير محدد',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Groups Section
          const Text(
            'المجموعات المسجل فيها',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, child) {
              final groupsAsync = ref.watch(childGroupsProvider(this.child.id));

              return groupsAsync.when(
                loading: () => const LoadingIndicator(),
                error: (error, stack) =>
                    app_error.AppErrorWidget(message: error.toString()),
                data: (groupIds) {
                  if (groupIds.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.group_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'لا يوجد مجموعات مسجل فيها',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: groupIds.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: Icon(Icons.group, color: Colors.green[700]),
                          ),
                          title: Text('مجموعة ${index + 1}'),
                          subtitle: Text('ID: ${groupIds[index]}'),
                          // TODO: Fetch and display actual group names
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TasksTab extends ConsumerWidget {
  final ChildModel child;

  const _TasksTab({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(childTasksControllerProvider(child.id));

    return tasksAsync.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) =>
          app_error.AppErrorWidget(message: error.toString()),
      data: (tasks) {
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مهام مسندة',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(
                    task.status,
                  ).withOpacity(0.2),
                  child: Icon(
                    _getStatusIcon(task.status),
                    color: _getStatusColor(task.status),
                  ),
                ),
                title: Text(
                  'مهمة ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الحالة: ${task.statusDisplay}'),
                    if (task.mark != null) Text('العلامة: ${task.mark}'),
                    Text(
                      'تاريخ التعيين: ${task.assignedAt.toString().split(' ')[0]}',
                    ),
                  ],
                ),
                trailing: task.isCompleted
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.pending:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.inProgress:
        return Icons.pending;
      case TaskStatus.pending:
        return Icons.schedule;
    }
  }
}

class _ProgressTab extends ConsumerWidget {
  final ChildModel child;

  const _ProgressTab({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(childProgressControllerProvider(child.id));

    return progressAsync.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) =>
          app_error.AppErrorWidget(message: error.toString()),
      data: (progress) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'ملخص التقدم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ProgressItem(
                            icon: Icons.assignment,
                            label: 'إجمالي المهام',
                            value: progress['totalTasks']?.toString() ?? '0',
                            color: Colors.blue,
                          ),
                          _ProgressItem(
                            icon: Icons.check_circle,
                            label: 'المهام المكتملة',
                            value:
                                progress['completedTasks']?.toString() ?? '0',
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ProgressItem(
                            icon: Icons.percent,
                            label: 'نسبة الإنجاز',
                            value:
                                '${progress['completionRate']?.toStringAsFixed(1) ?? '0'}%',
                            color: Colors.orange,
                          ),
                          _ProgressItem(
                            icon: Icons.star,
                            label: 'متوسط العلامات',
                            value:
                                progress['averageMark']?.toStringAsFixed(1) ??
                                '0',
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Recent Activity
              const Text(
                'النشاط الأخير',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _ActivityItem(
                        icon: Icons.assignment_turned_in,
                        title: 'مهمة مكتملة',
                        subtitle: 'تم إكمال مهمة جديدة',
                        time: 'منذ ساعتين',
                        color: Colors.green,
                      ),
                      const Divider(),
                      _ActivityItem(
                        icon: Icons.assignment,
                        title: 'مهمة جديدة',
                        subtitle: 'تم إسناد مهمة جديدة',
                        time: 'منذ يوم',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProgressItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }
}
