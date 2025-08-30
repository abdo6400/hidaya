import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/children_controller.dart';
import '../../controllers/child_tasks_controller.dart';
import '../../models/child_model.dart';
import '../../services/group_children_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart' as app_error;

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
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
          appBar: AppBar(title: const Text('لوحة تحكم الوالدين')),
          body: _ChildrenList(parentId: user.id),
        ),
      ),
    );
  }
}

class _ChildrenList extends ConsumerWidget {
  final String parentId;

  const _ChildrenList({required this.parentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenControllerProvider(parentId));

    return children.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) =>
          app_error.AppErrorWidget(message: error.toString()),
      data: (childrenList) {
        if (childrenList.isEmpty) {
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
                  'لا يوجد أطفال مسجلين',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'سيتم إضافة الأطفال من قبل الإدارة',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: childrenList.length,
          itemBuilder: (context, index) {
            final child = childrenList[index];
            return _ChildCard(child: child);
          },
        );
      },
    );
  }
}

class _ChildCard extends ConsumerStatefulWidget {
  final ChildModel child;

  const _ChildCard({required this.child});

  @override
  ConsumerState<_ChildCard> createState() => _ChildCardState();
}

class _ChildCardState extends ConsumerState<_ChildCard> {
  final GroupChildrenService _groupChildrenService = GroupChildrenService();
  late Future<List<String>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _groupChildrenService.getGroupsForChild(widget.child.id);
  }

  @override
  Widget build(BuildContext context) {
    final childProgress = ref.watch(
      childProgressControllerProvider(widget.child.id),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(
                widget.child.name.substring(0, 1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.child.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'العمر: ${widget.child.age}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Groups
                _buildGroupsSection(),
                const SizedBox(height: 16),

                // Progress
                _buildProgressSection(childProgress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsSection() {
    return FutureBuilder<List<String>>(
      future: _groupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final groups = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المجموعات المسجل فيها:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (groups.isEmpty)
              Text(
                'غير مسجل في أي مجموعة',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              )
            else
              ...groups
                  .map(
                    (groupId) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.group, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'المجموعة: $groupId', // TODO: Get group name
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
          ],
        );
      },
    );
  }

  Widget _buildProgressSection(AsyncValue progress) {
    return progress.when(
      loading: () => const SizedBox(
        height: 20,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stack) => Text(
        'خطأ في تحميل التقدم: $error',
        style: const TextStyle(color: Colors.red),
      ),
      data: (progressData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'التقدم العام:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ProgressItem(
                    title: 'إجمالي المهام',
                    value: progressData['totalTasks'].toString(),
                    icon: Icons.assignment,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProgressItem(
                    title: 'المهام المكتملة',
                    value: progressData['completedTasks'].toString(),
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
                  child: _ProgressItem(
                    title: 'نسبة الإنجاز',
                    value:
                        '${progressData['completionRate'].toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProgressItem(
                    title: 'متوسط الدرجات',
                    value: progressData['averageMark'].toStringAsFixed(1),
                    icon: Icons.grade,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProgressItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
