import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/children_controller.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedChildIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final childrenAsync = ref.watch(childrenControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: childrenAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, stack) => app_error.AppErrorWidget(message: error.toString()),
        data: (children) {
          // Filter children for current parent
          final parentChildren = children.where((child) => child.parentId == authState?.id).toList();
          
          if (parentChildren.isEmpty) {
            return _buildEmptyState();
          }

          // Ensure selected index is valid
          if (_selectedChildIndex >= parentChildren.length) {
            _selectedChildIndex = 0;
          }

          final selectedChild = parentChildren[_selectedChildIndex];
          final childProgress = _getChildProgress(selectedChild.id);

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
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
                              Icons.trending_up,
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
                                  'متابعة التقدم',
                                  style: AppTheme.islamicTitleStyle.copyWith(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'متابعة تقدم أولادك الأكاديمي',
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
                ),
              ),

              // Child Selector
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر الطفل',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: parentChildren.length,
                          itemBuilder: (context, index) {
                            final child = parentChildren[index];
                            final isSelected = index == _selectedChildIndex;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedChildIndex = index;
                                });
                              },
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: isSelected ? Colors.white : AppTheme.primaryColor.withOpacity(0.1),
                                      child: Text(
                                        child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                                        style: TextStyle(
                                          color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      child.name,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : AppTheme.textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress Overview
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نظرة عامة على التقدم',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProgressOverview(childProgress),
                    ],
                  ),
                ),
              ),

              // Progress Chart
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رسم بياني للتقدم',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProgressChart(childProgress),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أطفال مسجلين',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإضافة طفل أولاً لمتابعة تقدمه',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Generate sample progress data for demonstration
  // In a real app, this would come from Firebase
  List<Map<String, dynamic>> _getChildProgress(String childId) {
    // This is sample data - in production, fetch from Firebase
    final now = DateTime.now();
    final List<Map<String, dynamic>> progress = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      progress.add({
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'memorization': 70 + (i * 2) + (childId.hashCode % 20),
        'attendance': i == 3 ? 0 : 1, // One day absent
        'behavior': 80 + (i * 2) + (childId.hashCode % 15),
        'homework': 85 + (i * 2) + (childId.hashCode % 10),
      });
    }
    
    return progress;
  }

  Widget _buildProgressOverview(List<Map<String, dynamic>> progress) {
    if (progress.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('لا توجد بيانات تقدم متاحة'),
        ),
      );
    }

    // Calculate averages
    final totalMemorization = progress.map((p) => p['memorization'] as int).reduce((a, b) => a + b);
    final totalBehavior = progress.map((p) => p['behavior'] as int).reduce((a, b) => a + b);
    final totalHomework = progress.map((p) => p['homework'] as int).reduce((a, b) => a + b);
    final totalAttendance = progress.map((p) => p['attendance'] as int).reduce((a, b) => a + b);
    
    final avgMemorization = totalMemorization / progress.length;
    final avgBehavior = totalBehavior / progress.length;
    final avgHomework = totalHomework / progress.length;
    final attendanceRate = (totalAttendance / progress.length) * 100;

    return Row(
      children: [
                 Expanded(
           child: _buildProgressCard(
             'الحفظ',
             avgMemorization.toDouble(),
             Icons.book,
             AppTheme.primaryColor,
           ),
         ),
         const SizedBox(width: 12),
         Expanded(
           child: _buildProgressCard(
             'السلوك',
             avgBehavior.toDouble(),
             Icons.psychology,
             AppTheme.successColor,
           ),
         ),
         const SizedBox(width: 12),
         Expanded(
           child: _buildProgressCard(
             'الواجب',
             avgHomework.toDouble(),
             Icons.assignment,
             AppTheme.warningColor,
           ),
         ),
         const SizedBox(width: 12),
         Expanded(
           child: _buildProgressCard(
             'الحضور',
             attendanceRate.toDouble(),
             Icons.check_circle,
             AppTheme.infoColor,
             isPercentage: true,
           ),
         ),
      ],
    );
  }

  Widget _buildProgressCard(String title, double value, IconData icon, Color color, {bool isPercentage = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${value.round()}${isPercentage ? '%' : ''}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(List<Map<String, dynamic>> progress) {
    if (progress.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('لا توجد بيانات تقدم متاحة'),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تقدم الأسبوع',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: progress.length,
                itemBuilder: (context, index) {
                  final data = progress[index];
                  final memorization = data['memorization'] as int;
                  final behavior = data['behavior'] as int;
                  final homework = data['homework'] as int;
                  final attendance = data['attendance'] as int;
                  
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  height: (memorization / 100) * 120,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  height: (behavior / 100) * 120,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  height: (homework / 100) * 120,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['date'].toString().substring(5), // Show MM-DD
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Icon(
                          attendance == 1 ? Icons.check_circle : Icons.cancel,
                          color: attendance == 1 ? AppTheme.successColor : AppTheme.errorColor,
                          size: 16,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('الحفظ', AppTheme.primaryColor),
                _buildLegendItem('السلوك', AppTheme.successColor),
                _buildLegendItem('الواجب', AppTheme.warningColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
