import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/index.dart';
import '../../bloc/index.dart';
import '../../models/index.dart';
import '../forms/add_student_form.dart';
import '../forms/add_result_form.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/filter_chip.dart';
import 'student_details_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, highScore, lowScore, attendance

  @override
  void initState() {
    super.initState();
    context.read<StudentsBloc>().add(const LoadStudents());
  }

  List<Student> _filterStudents(List<Student> students) {
    var filtered = students.where((student) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!student.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Score filter
      switch (_selectedFilter) {
        case 'highScore':
          return student.totalGradedScore >= 80;
        case 'lowScore':
          return student.totalGradedScore < 50;
        case 'attendance':
          return student.attendanceCount > 0;
        default:
          return true;
      }
    }).toList();

    // Sort by score (highest first)
    filtered.sort((a, b) => b.totalGradedScore.compareTo(a.totalGradedScore));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.students),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
       
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
            final filteredStudents = _filterStudents(state.students);
            
            return Column(
              children: [
                // Search Bar
                CustomSearchBar(
                  hintText: 'البحث عن الطلاب...',
                  onSearchChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
                
                // Filter Chips
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CustomFilterChip(
                        label: 'الكل',
                        isSelected: _selectedFilter == 'all',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'all';
                          });
                        },
                        icon: Icons.list,
                      ),
                      const SizedBox(width: 8),
                      CustomFilterChip(
                        label: 'درجات عالية',
                        isSelected: _selectedFilter == 'highScore',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'highScore';
                          });
                        },
                        icon: Icons.trending_up,
                      ),
                      const SizedBox(width: 8),
                      CustomFilterChip(
                        label: 'درجات منخفضة',
                        isSelected: _selectedFilter == 'lowScore',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'lowScore';
                          });
                        },
                        icon: Icons.trending_down,
                      ),
                      const SizedBox(width: 8),
                      CustomFilterChip(
                        label: 'حضور',
                        isSelected: _selectedFilter == 'attendance',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'attendance';
                          });
                        },
                        icon: Icons.check_circle,
                      ),
                    ],
                  ),
                ),
                
                // Students List
                Expanded(
                  child: filteredStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isNotEmpty || _selectedFilter != 'all'
                                    ? Icons.search_off
                                    : Icons.school_outlined,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty || _selectedFilter != 'all'
                                    ? 'لا توجد نتائج للبحث'
                                    : 'لا يوجد طلاب مسجلين',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty || _selectedFilter != 'all'
                                    ? 'جرب تغيير البحث أو الفلتر'
                                    : 'اضغط على + لإضافة طالب جديد',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  student.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('المجموع: ${student.totalGradedScore.toStringAsFixed(1)}'),
                                    Text('الحضور: ${student.attendanceCount}'),
                                    Text('الشيخ: ${student.sheikhName}'),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit':
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => AddStudentForm(
                                              student: student,
                                            ),
                                          ),
                                        );
                                        break;
                                      case 'delete':
                                        _showDeleteDialog(context, student.id, student.name);
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
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => StudentDetailsScreen(
                                        student: student,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddStudentForm.showAsDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خيارات التصفية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('الكل'),
              leading: Radio(
                value: 'all',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('درجات عالية (80+)'),
              leading: Radio(
                value: 'highScore',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('درجات منخفضة (<50)'),
              leading: Radio(
                value: 'lowScore',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('حضور'),
              leading: Radio(
                value: 'attendance',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المجموع الكلي: ${student.totalGradedScore.toStringAsFixed(1)}'),
            Text('عدد مرات الحضور: ${student.attendanceCount}'),
            Text('تاريخ التسجيل: ${student.createdAt.toString().split(' ')[0]}'),
            const SizedBox(height: 16),
            const Text(
              'النتائج الأخيرة:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('لا توجد نتائج مسجلة بعد'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddResultForm(studentId: student.id),
                ),
              );
            },
            child: const Text('إضافة نتيجة'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String studentId, String studentName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الطالب "$studentName"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<StudentsBloc>().add(DeleteStudent(studentId));
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
}
