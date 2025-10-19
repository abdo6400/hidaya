import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/index.dart';
import '../../bloc/index.dart';
import '../../widgets/dashboard/summary_card.dart';
import '../../widgets/dashboard/quick_action_button.dart';
import '../forms/add_student_form.dart';
import '../forms/add_task_form.dart';
import '../forms/add_result_form.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboardStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          } else if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(const LoadDashboardStats());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          } else if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const RefreshDashboardStats());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // // Welcome Section
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     gradient: AppColors.primaryGradient,
                    //     borderRadius: BorderRadius.circular(16),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: AppColors.shadow,
                    //         blurRadius: 8,
                    //         offset: const Offset(0, 4),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text(
                    //         'مرحباً بك في نظام متابعة حفظ القرآن',
                    //         style: TextStyle(
                    //           color: AppColors.white,
                    //           fontSize: 24,
                    //           fontWeight: FontWeight.bold,
                    //           fontFamily: 'Cairo',
                    //         ),
                    //       ),
                    //       const SizedBox(height: 8),
                    //       Text(
                    //         'إدارة شاملة لطلاب القرآن الكريم',
                    //         style: TextStyle(
                    //           color: AppColors.white.withOpacity(0.9),
                    //           fontSize: 16,
                    //           fontFamily: 'Cairo',
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 24),

                    // Summary Cards
                    Text(
                      'نظرة عامة',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: constraints.maxWidth > 600 ? 1.3 : 1.1,
                      children: [
                        SummaryCard(
                          title: AppStrings.totalStudents,
                          value: state.stats.studentCount.toString(),
                          icon: Icons.school,
                          color: AppColors.primary,
                          onTap: () => context.go('/students'),
                        ),
                        SummaryCard(
                          title: AppStrings.totalSheikhs,
                          value: state.stats.sheikhCount.toString(),
                          icon: Icons.person,
                          color: AppColors.accent,
                          onTap: () => context.go('/sheikhs'),
                        ),
                        SummaryCard(
                          title: AppStrings.totalTasks,
                          value: state.stats.taskCount.toString(),
                          icon: Icons.assignment,
                          color: AppColors.info,
                          onTap: () => context.go('/tasks'),
                        ),
                        SummaryCard(
                          title: AppStrings.totalPoints,
                          value: state.stats.totalPoints.toStringAsFixed(1),
                          icon: Icons.star,
                          color: AppColors.success,
                          onTap: () => context.go('/reports'),
                        ),
                      ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Quick Actions
                    Text(
                      'إجراءات سريعة',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: constraints.maxWidth > 600 ? 1.5 : 1.7,
                      children: [
                        QuickActionButton(
                          title: 'إضافة طالب جديد',
                          icon: Icons.person_add,
                          color: AppColors.primary,
                          onTap: () {
                            AddStudentForm.showAsDialog(context);
                          },
                        ),
                        QuickActionButton(
                          title: 'إضافة مهمة جديدة',
                          icon: Icons.add_task,
                          color: AppColors.accent,
                          onTap: () {
                            AddTaskForm.showAsDialog(context);
                          },
                        ),
                        QuickActionButton(
                          title: 'تسجيل نتيجة',
                          icon: Icons.check_circle,
                          color: AppColors.success,
                          onTap: () {
                            AddResultForm.showAsDialog(context);
                          },
                        ),
                        QuickActionButton(
                          title: 'عرض التقارير',
                          icon: Icons.analytics,
                          color: AppColors.info,
                          onTap: () => context.go('/reports'),
                        ),
                      ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
