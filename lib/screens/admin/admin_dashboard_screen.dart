import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/schedule_groups_controller.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/dashboard_stats_card.dart';
import 'package:hidaya/widgets/quick_action_button.dart';
import 'package:hidaya/utils/app_theme.dart';
import '../../providers/firebase_providers.dart';
import 'create_group_screen.dart';
import 'group_details_screen.dart';
import 'groups_screen.dart';
import 'reports_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final Function(int)? onTabChange;

  const AdminDashboardScreen({super.key, this.onTabChange});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Welcome Header
          SliverToBoxAdapter(child: _buildWelcomeHeader()),

          // Stats Cards
          SliverToBoxAdapter(child: _buildStatsSection()),

          // Quick Actions
          SliverToBoxAdapter(child: _buildQuickActionsSection()),

          // // Recent Groups
          // SliverToBoxAdapter(child: _buildRecentGroupsSection()),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: 
                    Text(
                      'مرحباً بك في لوحة الإدارة',
                      style: AppTheme.islamicTitleStyle.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    
                  
               
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات سريعة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(dashboardStatsProvider);

              return statsAsync.when(
                data: (stats) => DashboardStatsGrid(
                  cards: [
                    DashboardStatsCard(
                      title: 'إجمالي المحفظين',
                      value: '${stats['totalSheikhs'] ?? 0}',
                      icon: Icons.person,
                      color: AppTheme.successColor,
                      onTap: () {},
                    ),
                    DashboardStatsCard(
                      title: 'إجمالي أولياء الأمور',
                      value: '${stats['totalParents'] ?? 0}',
                      icon: Icons.family_restroom,
                      color: AppTheme.accentColor,
                      onTap: () {},
                    ),
                    DashboardStatsCard(
                      title: 'الطلاب المسجلين',
                      value: '${stats['totalChildren'] ?? 0}',
                      icon: Icons.school,
                      color: AppTheme.infoColor,
                      onTap: () {},
                    ),
                    DashboardStatsCard(
                      title: 'الفئات التعليمية',
                      value: '${stats['totalCategories'] ?? 0}',
                      icon: Icons.category,
                      color: AppTheme.warningColor,
                      onTap: () {},
                    ),
                  ],
                ),
                loading: () => const LoadingIndicator(),
                error: (error, stack) => app_error.AsyncErrorWidget(
                  error: error,
                  stackTrace: stack,
                  onRetry: () => ref.refresh(dashboardStatsProvider),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراءات سريعة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          QuickActionsGrid(
            actions: [
              // QuickActionButton(
              //   title: 'إضافة محفظ',
              //   icon: Icons.person_add,
              //   onTap: () => _navigateToSheikhs(),
              //   color: AppTheme.primaryColor,
              // ),
              // QuickActionButton(
              //   title: 'إنشاء فئة',
              //   icon: Icons.category,
              //   onTap: () => _navigateToCategories(),
              //   color: AppTheme.successColor,
              // ),
              QuickActionButton(
                title: 'إدارة المجموعات',
                icon: Icons.groups,
                onTap: () => _navigateToGroups(),
                color: AppTheme.warningColor,
              ),
              // QuickActionButton(
              //   title: 'إضافة مهمة',
              //   icon: Icons.task,
              //   onTap: () => _navigateToTasks(),
              //   color: AppTheme.accentColor,
              // ),
              // QuickActionButton(
              //   title: 'إضافة ولي أمر',
              //   icon: Icons.person,
              //   onTap: () => _navigateToParents(),
              //   color: AppTheme.infoColor,
              // ),
              QuickActionButton(
                title: 'التقارير',
                icon: Icons.analytics,
                onTap: () => _navigateToReports(),
                color: AppTheme.accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGroupsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _createNewGroup(),
                icon: const Icon(Icons.add),
              ),
              Text(
                'المجموعات الحديثة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToGroups(),
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final groupsAsync = ref.watch(scheduleGroupsControllerProvider);

              return groupsAsync.when(
                loading: () => const LoadingIndicator(),
                error: (error, stack) =>
                    app_error.AppErrorWidget(message: error.toString()),
                data: (groups) {
                  if (groups.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Show only recent 3 groups
                  final recentGroups = groups.take(3).toList();

                  return Column(
                    children: recentGroups
                        .map((group) => _buildGroupCard(group))
                        .toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.groups_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد مجموعات',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على + لإنشاء مجموعة جديدة',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(ScheduleGroupModel group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: InkWell(
          onTap: () => _viewGroupDetails(group),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.groups,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.description.isNotEmpty
                            ? group.description
                            : 'لا يوجد وصف',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatusChip(
                            group.isActive ? 'نشط' : 'غير نشط',
                            group.isActive
                                ? AppTheme.successColor
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          _buildStatusChip(
                            group.daysDisplay,
                            AppTheme.infoColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Navigation methods
  void _createNewGroup() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateGroupScreen()));

    if (result == true) {
      ref.invalidate(scheduleGroupsControllerProvider);
    }
  }

  void _viewGroupDetails(ScheduleGroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupDetailsScreen(group: group)),
    ).then((_) {
      ref.invalidate(scheduleGroupsControllerProvider);
    });
  }

  void _navigateToSheikhs() {
    // Navigate to sheikhs tab (index 1)
    widget.onTabChange?.call(1);
  }

  void _navigateToCategories() {
    // Navigate to categories tab (index 2)
    widget.onTabChange?.call(2);
  }

  void _navigateToTasks() {
    // Navigate to tasks tab (index 3)
    widget.onTabChange?.call(3);
  }

  void _navigateToParents() {
    // Navigate to schedules tab (index 4)
    widget.onTabChange?.call(4);
  }

  void _navigateToReports() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportsScreen()),
    );
  }

  void _navigateToGroups() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupsScreen()),
    );
  }


}
