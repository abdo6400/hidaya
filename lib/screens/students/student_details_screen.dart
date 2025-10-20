import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../constants/index.dart';
import '../../bloc/index.dart';
import '../../models/index.dart';
import '../forms/add_result_form.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Student student;

  const StudentDetailsScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    context.read<ResultsBloc>().add(LoadResultsByStudent(widget.student.id));
  }

  List<Result> _filterResults(List<Result> results) {
    return results.where((result) {
      // Date filter - check if result was created within the date range
      if (_startDate != null && result.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && result.date.isAfter(_endDate!.add(const Duration(days: 1)))) {
        return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              AddResultForm.showAsDialog(
                context,
                studentId: widget.student.id,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Student Info Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.white.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student.name,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تاريخ التسجيل: ${widget.student.createdAt.toString().split(' ')[0]}',
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'إجمالي النقاط',
                        widget.student.totalGradedScore.toStringAsFixed(1),
                        Icons.star,
                        AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'مرات الحضور',
                        widget.student.attendanceCount.toString(),
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results History
          Expanded(
            child: BlocBuilder<ResultsBloc, ResultsState>(
              builder: (context, state) {
                if (state is ResultsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                } else if (state is ResultsError) {
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
                            context.read<ResultsBloc>().add(
                              LoadResultsByStudent(widget.student.id),
                            );
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                } else if (state is ResultsLoaded) {
                  if (state.results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد نتائج مسجلة',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'اضغط على + لإضافة نتيجة جديدة',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter results by date
                  final filteredResults = _filterResults(state.results);
                  
                  if (filteredResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_list_off,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _startDate != null || _endDate != null 
                                ? 'لا توجد نتائج في الفترة المحددة'
                                : 'لا توجد نتائج مسجلة بعد',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final result = filteredResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: result.score != null
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.accent.withOpacity(0.1),
                            child: Icon(
                              result.score != null ? Icons.grade : Icons.check_circle,
                              color: result.score != null
                                  ? AppColors.primary
                                  : AppColors.accent,
                            ),
                          ),
                          title: Text(
                            result.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (result.score != null)
                                Text('الدرجة: ${result.score!.toStringAsFixed(1)}')
                              else
                                Text(
                                  'الحضور: ${result.attendance == true ? 'نعم' : 'لا'}',
                                ),
                              Text('التاريخ: ${result.date.toString().split(' ')[0]}'),
                              Text('اليوم: ${DateFormat('EEEE', 'ar_SA').format(result.date)}')
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AddResultForm(
                                        result: result,
                                      ),
                                    ),
                                  );
                                  break;
                                case 'delete':
                                  _showDeleteDialog(context, result.id, result.title);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('تعديل'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('حذف'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.9),
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String resultId, String resultTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف النتيجة "$resultTitle"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ResultsBloc>().add(DeleteResult(resultId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تصفية النتائج'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Start Date
                ListTile(
                  title: const Text('من تاريخ'),
                  subtitle: Text(_startDate?.toString().split(' ')[0] ?? 'غير محدد'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                ),
                
                // End Date
                ListTile(
                  title: const Text('إلى تاريخ'),
                  subtitle: Text(_endDate?.toString().split(' ')[0] ?? 'غير محدد'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                ),
                
                // Clear Filters Button
                if (_startDate != null || _endDate != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    child: const Text('مسح الفلاتر'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {}); // Refresh the main screen
              },
              child: const Text('تطبيق'),
            ),
          ],
        ),
      ),
    );
  }
}
