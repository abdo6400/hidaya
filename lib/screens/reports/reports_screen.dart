import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/index.dart';
import '../../bloc/index.dart';
import '../../models/index.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<StudentsBloc>().add(const LoadStudents());
  }

  List<Student> _filterStudents(List<Student> students) {
    return students.where((student) {
      // Search filter
      if (_searchQuery.isNotEmpty && 
          !student.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      
      // Date filter - check if student was created within the date range
      if (_startDate != null && student.createdAt.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && student.createdAt.isAfter(_endDate!.add(const Duration(days: 1)))) {
        return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reports),
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
        ],
      ),
      body: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          if (state is StudentsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          } else if (state is StudentsError) {
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
                      context.read<StudentsBloc>().add(const LoadStudents());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          } else if (state is StudentsLoaded) {
            // Filter and sort students by total score (highest first)
            final filteredStudents = _filterStudents(state.students);
            final sortedStudents = List<Student>.from(filteredStudents)
              ..sort((a, b) => b.totalGradedScore.compareTo(a.totalGradedScore));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
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
                        const Text(
                          'ترتيب الطلاب',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'حسب إجمالي النقاط المحققة',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Students Ranking
                  if (sortedStudents.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا يوجد طلاب مسجلين',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedStudents.length,
                      itemBuilder: (context, index) {
                        final student = sortedStudents[index];
                        final rank = index + 1;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getRankColor(rank).withOpacity(0.1),
                              child: Text(
                                rank.toString(),
                                style: TextStyle(
                                  color: _getRankColor(rank),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              student.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('النقاط: ${student.totalGradedScore.toStringAsFixed(1)}'),
                                Text('الحضور: ${student.attendanceCount} مرة'),
                              ],
                            ),
                            trailing: Icon(
                              _getRankIcon(rank),
                              color: _getRankColor(rank),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.accent; // Gold for first place
      case 2:
        return AppColors.textSecondary; // Silver for second place
      case 3:
        return const Color(0xFFCD7F32); // Bronze for third place
      default:
        return AppColors.primary;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.workspace_premium; // Medal
      case 3:
        return Icons.military_tech; // Award
      default:
        return Icons.person;
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تصفية التقارير'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Field
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'البحث بالاسم',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
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
                if (_startDate != null || _endDate != null || _searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                        _searchQuery = '';
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