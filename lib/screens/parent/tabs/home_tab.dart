import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/providers/firebase_providers.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Welcome Header
        SliverToBoxAdapter(child: _buildWelcomeHeader()),

        // Quick Stats
        SliverToBoxAdapter(
          child: Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authControllerProvider);
              return authState != null
                  ? _buildQuickStats(context, ref, authState.id)
                  : const LoadingIndicator();
            },
          ),
        ),

        // Recent Activities
        SliverToBoxAdapter(child: _buildRecentActivities(context)),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
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
                  Icons.family_restroom,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك في هداية',
                      style: AppTheme.islamicTitleStyle.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تابع تعليم أبنائك بكل سهولة',
                      style: AppTheme.arabicTextStyle.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref, String parentId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص سريع',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final parentStatsAsync = ref.watch(parentStatsProvider(parentId));
              final childrenAsync = ref.watch(
                childrenByParentProvider(parentId),
              );

              return parentStatsAsync.when(
                data: (stats) {
                  return childrenAsync.when(
                    data: (children) {
                      final approvedChildren = children
                          .where((child) => child.isApproved)
                          .length;
                      final pendingChildren =
                          children.length - approvedChildren;

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'الأبناء المسجلين',
                                  '${children.length}',
                                  Icons.child_care,
                                  AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'الأبناء المعتمدين',
                                  '$approvedChildren',
                                  Icons.check_circle,
                                  AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'في انتظار الاعتماد',
                                  '$pendingChildren',
                                  Icons.pending,
                                  AppTheme.warningColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'المحفظين',
                                  '${stats['totalSheikhs'] ?? 0}',
                                  Icons.person,
                                  AppTheme.infoColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const LoadingIndicator(),
                    error: (error, stack) => app_error.AsyncErrorWidget(
                      error: error,
                      stackTrace: stack,
                      onRetry: () =>
                          ref.refresh(childrenByParentProvider(parentId)),
                    ),
                  );
                },
                loading: () => const LoadingIndicator(),
                error: (error, stack) => app_error.AsyncErrorWidget(
                  error: error,
                  stackTrace: stack,
                  onRetry: () => ref.refresh(parentStatsProvider(parentId)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المهام اليومية',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // For now, showing static activities. In the future, this should come from Firebase
          _buildActivityCard(
            context,
            'تم إكمال مهمة حفظ سورة الفاتحة',
            'أحمد محمد',
            'منذ ساعتين',
            Icons.task_alt,
            AppTheme.successColor,
          ),
          _buildActivityCard(
            context,
            'حضور درس التلاوة',
            'فاطمة أحمد',
            'منذ 3 ساعات',
            Icons.school,
            AppTheme.infoColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
