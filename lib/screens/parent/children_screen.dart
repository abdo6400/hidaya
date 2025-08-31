import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/constants.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:hidaya/providers/firebase_providers.dart';
import 'package:hidaya/controllers/children_controller.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:quickalert/quickalert.dart';

class ChildrenScreen extends ConsumerStatefulWidget {
  const ChildrenScreen({super.key});

  @override
  ConsumerState<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends ConsumerState<ChildrenScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    
    if (authState == null) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
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
                              'أولادي',
                              style: AppTheme.islamicTitleStyle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تابع تعليم أبنائك وتقدمهم',
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

          // Children List
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'قائمة الأبناء',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddChildDialog(),
                        icon: const Icon(Icons.person_add),
                        label: const Text('إضافة ابن'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Children List
                  Consumer(
                    builder: (context, ref, child) {
                      final childrenAsync = ref.watch(childrenByParentProvider(authState.id));
                      
                      return childrenAsync.when(
                        data: (children) {
                          if (children.isEmpty) {
                            return _buildEmptyState();
                          }
                          
                          return Column(
                            children: children.map((child) => _buildChildCard(child)).toList(),
                          );
                        },
                        loading: () => const LoadingIndicator(),
                        error: (error, stack) => app_error.AsyncErrorWidget(
                          error: error,
                          stackTrace: stack,
                          onRetry: () => ref.refresh(childrenByParentProvider(authState.id)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(ChildModel child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        child.name[0],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'العمر: ${child.age} سنة',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              child.isApproved ? Icons.check_circle : Icons.pending,
                              size: 16,
                              color: child.isApproved ? AppTheme.successColor : AppTheme.warningColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              child.isApproved ? 'معتمد' : 'في انتظار الاعتماد',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: child.isApproved ? AppTheme.successColor : AppTheme.warningColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, child),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('تعديل'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'progress',
                        child: ListTile(
                          leading: Icon(Icons.trending_up),
                          title: Text('التقدم'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'attendance',
                        child: ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: Text('الحضور'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('حذف', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Progress Indicators
              Row(
                children: [
                  Expanded(
                    child: _buildProgressIndicator(
                      'معدل الحضور',
                      '95%',
                      Icons.calendar_today,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildProgressIndicator(
                      'التقدم في الحفظ',
                      '75%',
                      Icons.book,
                      AppTheme.successColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Additional Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات إضافية',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('تاريخ التسجيل:', '2024-01-15'),
                    _buildInfoRow('آخر حضور:', '2024-12-15'),
                    _buildInfoRow('المحفظ:', 'الشيخ أحمد محمد'),
                    _buildInfoRow('الفئة:', 'حفظ القرآن الكريم'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد أبناء مسجلين',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإضافة أبنائك للبدء في متابعة تعليمهم',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddChildDialog(),
            icon: const Icon(Icons.person_add),
            label: const Text('إضافة ابن جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, ChildModel child) {
    switch (action) {
      case 'edit':
        _showEditChildDialog(child);
        break;
      case 'progress':
        _showProgressDialog(child);
        break;
      case 'attendance':
        _showAttendanceDialog(child);
        break;
      case 'delete':
        _showDeleteConfirmation(child);
        break;
    }
  }

  void _showAddChildDialog() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة ابن جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الابن',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'العمر',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
                try {
                  final authState = ref.read(authControllerProvider);
                  if (authState != null) {
                                         final child = ChildModel(
                       id: '',
                       name: nameController.text,
                       age: ageController.text,
                       parentId: authState.id,
                       isApproved: false,
                       createdBy: authState.id,
                     );
                     
                     await ref.read(childrenControllerProvider.notifier).addChild(child);
                    Navigator.pop(context);
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                      text: 'تم إضافة الابن بنجاح',
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    text: 'حدث خطأ أثناء إضافة الابن',
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditChildDialog(ChildModel child) {
    final nameController = TextEditingController(text: child.name);
    final ageController = TextEditingController(text: child.age.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات الابن'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الابن',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'العمر',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
                                 try {
                   final updatedChild = ChildModel(
                     id: child.id,
                     name: nameController.text,
                     age: ageController.text,
                     parentId: child.parentId,
                     isApproved: child.isApproved,
                     createdBy: child.createdBy,
                   );
                   await ref.read(childrenControllerProvider.notifier).updateChild(updatedChild);
                  Navigator.pop(context);
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.success,
                    text: 'تم تحديث بيانات الابن بنجاح',
                  );
                } catch (e) {
                  Navigator.pop(context);
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    text: 'حدث خطأ أثناء تحديث البيانات',
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog(ChildModel child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تقدم ${child.name}'),
        content: const Text('سيتم عرض تفاصيل التقدم هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDialog(ChildModel child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('سجل حضور ${child.name}'),
        content: const Text('سيتم عرض سجل الحضور هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ChildModel child) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: 'هل أنت متأكد من حذف ${child.name}؟\nلا يمكن التراجع عن هذا الإجراء.',
      confirmBtnText: 'حذف',
      cancelBtnText: 'إلغاء',
      onConfirmBtnTap: () async {
        try {
          await ref.read(childrenControllerProvider.notifier).deleteChild(child.id);
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'تم حذف الابن بنجاح',
          );
        } catch (e) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: 'حدث خطأ أثناء حذف الابن',
          );
        }
      },
    );
  }
}
