import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/reports_controller.dart';
import '../../widgets/error_widget.dart' as app_error;
import '../../widgets/loading_indicator.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
        
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshReports(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Tab Bar
            TabBar(
              onTap: (index) => setState(() => _currentIndex = index),
              tabs: const [
                Tab(text: 'نظرة عامة'),
                Tab(text: 'أداء المجموعات'),
                Tab(text: 'أداء الأطفال'),
                Tab(text: 'أداء الشيوخ'),
              ],
            ),

            // Tab Content
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  _OverviewTab(),
                  _GroupPerformanceTab(),
                  _ChildPerformanceTab(),
                  _SheikhPerformanceTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshReports() {
    ref.invalidate(overallStatisticsProvider);
    ref.invalidate(groupPerformanceProvider);
    ref.invalidate(childPerformanceProvider);
    ref.invalidate(sheikhPerformanceProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(monthlyStatisticsProvider);
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  void _navigateToCreateGroup(BuildContext context) {
    Navigator.of(context).pushNamed('/admin/create-group');
  }

  void _navigateToTasks(BuildContext context) {
    Navigator.of(context).pushNamed('/admin/tasks');
  }

  void _navigateToSheikhs(BuildContext context) {
    Navigator.of(context).pushNamed('/admin/sheikhs');
  }

  void _navigateToChildren(BuildContext context) {
    Navigator.of(context).pushNamed('/admin/children');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallStats = ref.watch(overallStatisticsProvider);
    final monthlyStats = ref.watch(monthlyStatisticsProvider);
    final recentActivity = ref.watch(recentActivityProvider);

    return overallStats.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) =>
          app_error.AppErrorWidget(message: error.toString()),
      data: (stats) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Statistics Cards
              const Text(
                'الإحصائيات العامة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي المجموعات',
                      value: stats['totalGroups'].toString(),
                      icon: Icons.group,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'المجموعات النشطة',
                      value: stats['activeGroups'].toString(),
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
                    child: _StatCard(
                      title: 'إجمالي الأطفال',
                      value: stats['totalChildren'].toString(),
                      icon: Icons.child_care,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي الشيوخ',
                      value: stats['totalSheikhs'].toString(),
                      icon: Icons.person,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي المهام',
                      value: stats['totalTasks'].toString(),
                      icon: Icons.assignment,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'المهام المكتملة',
                      value: stats['completedTasks'].toString(),
                      icon: Icons.done_all,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'نسبة الإنجاز',
                      value: '${stats['completionRate'].toStringAsFixed(1)}%',
                      icon: Icons.trending_up,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Monthly Statistics
              monthlyStats.when(
                loading: () => const LoadingIndicator(),
                error: (error, stack) =>
                    app_error.AppErrorWidget(message: error.toString()),
                data: (monthlyData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إحصائيات الشهر الحالي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'المهام المكتملة',
                              value: monthlyData['completedTasks'].toString(),
                              icon: Icons.done,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'الأطفال الجدد',
                              value: monthlyData['newChildren'].toString(),
                              icon: Icons.person_add,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'المجموعات الجديدة',
                              value: monthlyData['newGroups'].toString(),
                              icon: Icons.group_add,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'إجراءات سريعة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'إنشاء مجموعة',
                      subtitle: 'إنشاء مجموعة جديدة',
                      icon: Icons.add_circle,
                      color: Colors.blue,
                      onTap: () => _navigateToCreateGroup(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'إدارة المهام',
                      subtitle: 'إنشاء وإدارة المهام',
                      icon: Icons.assignment,
                      color: Colors.orange,
                      onTap: () => _navigateToTasks(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'إدارة الشيوخ',
                      subtitle: 'إدارة حسابات الشيوخ',
                      icon: Icons.person,
                      color: Colors.purple,
                      onTap: () => _navigateToSheikhs(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'إدارة الأطفال',
                      subtitle: 'إدارة بيانات الأطفال',
                      icon: Icons.child_care,
                      color: Colors.green,
                      onTap: () => _navigateToChildren(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity
              recentActivity.when(
                loading: () => const LoadingIndicator(),
                error: (error, stack) =>
                    app_error.AppErrorWidget(message: error.toString()),
                data: (activities) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'النشاط الأخير',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (activities.isEmpty)
                        const Center(
                          child: Text(
                            'لا توجد أنشطة حديثة',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            return _ActivityCard(activity: activity);
                          },
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GroupPerformanceTab extends ConsumerWidget {
  const _GroupPerformanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupPerformance = ref.watch(groupPerformanceProvider);

    return groupPerformance.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) =>
          app_error.AppErrorWidget(message: error.toString()),
      data: (groups) {
        if (groups.isEmpty) {
          return const Center(child: Text('لا توجد مجموعات لعرض الأداء'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return _GroupPerformanceCard(group: group);
          },
        );
      },
    );
  }
}

class _ChildPerformanceTab extends ConsumerWidget {
  const _ChildPerformanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childPerformance = ref.watch(childPerformanceProvider);

    return childPerformance.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) =>
          app_error.AppErrorWidget(message: error.toString()),
      data: (children) {
        if (children.isEmpty) {
          return const Center(child: Text('لا توجد أطفال لعرض الأداء'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: children.length,
          itemBuilder: (context, index) {
            final child = children[index];
            return _ChildPerformanceCard(child: child);
          },
        );
      },
    );
  }
}

class _SheikhPerformanceTab extends ConsumerWidget {
  const _SheikhPerformanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheikhPerformance = ref.watch(sheikhPerformanceProvider);

    return sheikhPerformance.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) =>
          app_error.AppErrorWidget(message: error.toString()),
      data: (sheikhs) {
        if (sheikhs.isEmpty) {
          return const Center(child: Text('لا توجد شيوخ لعرض الأداء'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sheikhs.length,
          itemBuilder: (context, index) {
            final sheikh = sheikhs[index];
            return _SheikhPerformanceCard(sheikh: sheikh);
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
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

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final type = activity['type'] as String;
    final action = activity['action'] as String;
    final timestamp = activity['timestamp'] as DateTime;

    String title = '';
    String subtitle = '';
    IconData icon = Icons.info;

    if (type == 'task') {
      final childName = activity['childName'] as String;
      final taskTitle = activity['taskTitle'] as String;
      final status = activity['status'] as String;

      if (action == 'completed_task') {
        title = 'تم إكمال مهمة';
        subtitle = '$childName أكمل $taskTitle';
        icon = Icons.check_circle;
      } else {
        title = 'تم تعيين مهمة';
        subtitle = 'تم تعيين $taskTitle لـ $childName';
        icon = Icons.assignment;
      }
    } else if (type == 'assignment') {
      final childName = activity['childName'] as String;
      final groupName = activity['groupName'] as String;

      title = 'تم تعيين طفل';
      subtitle = '$childName تم تعيينه في $groupName';
      icon = Icons.person_add;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue[700]),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          _formatTimestamp(timestamp),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}

class _GroupPerformanceCard extends StatelessWidget {
  final Map<String, dynamic> group;

  const _GroupPerformanceCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group['groupName'] as String,
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
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'الشيخ: ${group['sheikhId']}',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PerformanceMetric(
                    label: 'الأطفال',
                    value: group['childrenCount'].toString(),
                    icon: Icons.child_care,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _PerformanceMetric(
                    label: 'المهام',
                    value: group['totalTasks'].toString(),
                    icon: Icons.assignment,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _PerformanceMetric(
                    label: 'المكتملة',
                    value: group['completedTasks'].toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PerformanceMetric(
                    label: 'نسبة الإنجاز',
                    value: '${group['completionRate'].toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                ),
                Expanded(
                  child: _PerformanceMetric(
                    label: 'متوسط الدرجات',
                    value: group['averageMark'].toStringAsFixed(1),
                    icon: Icons.grade,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildPerformanceCard extends StatelessWidget {
  final Map<String, dynamic> child;

  const _ChildPerformanceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    (child['childName'] as String).substring(0, 1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child['childName'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'العمر: ${child['age']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${child['groupsCount']} مجموعات',
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PerformanceMetric(
                    label: 'المهام',
                    value: child['totalTasks'].toString(),
                    icon: Icons.assignment,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _PerformanceMetric(
                    label: 'المكتملة',
                    value: child['completedTasks'].toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _PerformanceMetric(
                    label: 'نسبة الإنجاز',
                    value: '${child['completionRate'].toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _PerformanceMetric(
                    label: 'متوسط الدرجات',
                    value: child['averageMark'].toStringAsFixed(1),
                    icon: Icons.grade,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheikhPerformanceCard extends StatelessWidget {
  final Map<String, dynamic> sheikh;

  const _SheikhPerformanceCard({required this.sheikh});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, color: Colors.blue[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sheikh['sheikhName'] as String,
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
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${sheikh['groupsCount']} مجموعات',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PerformanceMetric(
                    label: 'الأطفال',
                    value: sheikh['totalChildren'].toString(),
                    icon: Icons.child_care,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _PerformanceMetric(
                    label: 'المهام',
                    value: sheikh['totalTasks'].toString(),
                    icon: Icons.assignment,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _PerformanceMetric(
                    label: 'المكتملة',
                    value: sheikh['completedTasks'].toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PerformanceMetric(
                    label: 'نسبة الإنجاز',
                    value: '${sheikh['completionRate'].toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                ),
                Expanded(
                  child: _PerformanceMetric(
                    label: 'متوسط الدرجات',
                    value: sheikh['averageMark'].toStringAsFixed(1),
                    icon: Icons.grade,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _PerformanceMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
