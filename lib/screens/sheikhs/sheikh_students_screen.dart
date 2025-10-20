import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/index.dart';
import '../../bloc/index.dart';
import '../../models/index.dart';
import '../students/student_details_screen.dart';

class SheikhStudentsScreen extends StatefulWidget {
  final Sheikh sheikh;

  const SheikhStudentsScreen({
    super.key,
    required this.sheikh,
  });

  @override
  State<SheikhStudentsScreen> createState() => _SheikhStudentsScreenState();
}

class _SheikhStudentsScreenState extends State<SheikhStudentsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<StudentsBloc>().add(LoadStudentsBySheikh(widget.sheikh.id));
  }

  List<Student> _filterStudents(List<Student> students) {
    var filtered = students.where((student) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          student.name.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesSearch;
    }).toList();

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلاب الشيخ ${widget.sheikh.name}'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocListener<StudentsBloc, StudentsState>(
        listener: (context, state) {
          if (state is StudentOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Reload students after successful operation
            context.read<StudentsBloc>().add(LoadStudentsBySheikh(widget.sheikh.id));
          } else if (state is StudentOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<StudentsBloc, StudentsState>(
          builder: (context, state) {
            if (state is StudentsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is StudentsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ في تحميل البيانات',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.error,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<StudentsBloc>().add(LoadStudentsBySheikh(widget.sheikh.id));
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is StudentsLoaded) {
              final filteredStudents = _filterStudents(state.students);

              return Column(
                children: [
                  // Search Bar
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'البحث عن الطلاب...',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontFamily: 'Cairo',
                        ),
                        prefixIcon: Icon(Icons.search, color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  // Students Count
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.people, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'عدد الطلاب: ${filteredStudents.length}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Students List
                  Expanded(
                    child: filteredStudents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: AppColors.textHint,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا يوجد طلاب مسجلين',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'لا يوجد طلاب مسجلين لدى هذا الشيخ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textHint,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              return _buildStudentCard(student);
                            },
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StudentDetailsScreen(student: student),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.success.withOpacity(0.1),
                    child: Icon(Icons.person, color: AppColors.success),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الشيخ: ${student.sheikhName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'view') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StudentDetailsScreen(student: student),
                          ),
                        );
                      } else if (value == 'remove') {
                        _showRemoveDialog(student);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('عرض التفاصيل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.person_remove, size: 20, color: AppColors.warning),
                            SizedBox(width: 8),
                            Text('إزالة من الشيخ', style: TextStyle(color: AppColors.warning)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.grade, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'إجمالي الدرجات: ${student.totalGradedScore.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.check_circle, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'عدد الحضور: ${student.attendanceCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإزالة'),
        content: Text('هل أنت متأكد من إزالة الطالب "${student.name}" من الشيخ "${widget.sheikh.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<StudentsBloc>().add(RemoveStudentFromSheikh(student.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
  }
}
