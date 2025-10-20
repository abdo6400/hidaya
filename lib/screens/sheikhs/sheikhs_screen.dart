import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/index.dart';
import '../../bloc/index.dart';
import '../../models/index.dart';
import '../forms/add_sheikh_form.dart';
import 'sheikh_students_screen.dart';

class SheikhsScreen extends StatefulWidget {
  const SheikhsScreen({super.key});

  @override
  State<SheikhsScreen> createState() => _SheikhsScreenState();
}

class _SheikhsScreenState extends State<SheikhsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<SheikhsBloc>().add(const LoadSheikhs());
  }

  List<Sheikh> _filterSheikhs(List<Sheikh> sheikhs) {
    var filtered = sheikhs.where((sheikh) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          sheikh.name.toLowerCase().contains(_searchQuery.toLowerCase());

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
        title: const Text('الشيوخ'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocBuilder<SheikhsBloc, SheikhsState>(
        builder: (context, state) {
          if (state is SheikhsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is SheikhsError) {
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
                      context.read<SheikhsBloc>().add(const LoadSheikhs());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is SheikhsLoaded) {
            final filteredSheikhs = _filterSheikhs(state.sheikhs);

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
                      hintText: 'البحث عن الشيوخ...',
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

                // Sheikhs List
                Expanded(
                  child: filteredSheikhs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off,
                                size: 64,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد شيوخ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'اضغط على + لإضافة شيخ جديد',
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
                          itemCount: filteredSheikhs.length,
                          itemBuilder: (context, index) {
                            final sheikh = filteredSheikhs[index];
                            return _buildSheikhCard(sheikh);
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
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddSheikhForm()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildSheikhCard(Sheikh sheikh) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sheikh.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'students') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SheikhStudentsScreen(sheikh: sheikh),
                        ),
                      );
                    } else if (value == 'edit') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddSheikhForm(sheikh: sheikh),
                        ),
                      );
                    } else if (value == 'delete') {
                      _showDeleteDialog(sheikh);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'students',
                      child: Row(
                        children: [
                          Icon(Icons.school, size: 20),
                          SizedBox(width: 8),
                          Text('عرض الطلاب'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Sheikh sheikh) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الشيخ "${sheikh.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SheikhsBloc>().add(DeleteSheikh(sheikh.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف الشيخ "${sheikh.name}"'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
