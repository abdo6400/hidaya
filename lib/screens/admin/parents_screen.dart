import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/constants.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/controllers/users_controller.dart';
import 'package:hidaya/controllers/children_controller.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:quickalert/quickalert.dart';

class ParentsScreen extends ConsumerStatefulWidget {
  const ParentsScreen({super.key});

  @override
  ConsumerState<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends ConsumerState<ParentsScreen> {
  @override
  Widget build(BuildContext context) {
    final parentsAsync = ref.watch(usersControllerProvider);
    final childrenAsync = ref.watch(childrenControllerProvider);
    
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
                              'إدارة أولياء الأمور',
                              style: AppTheme.islamicTitleStyle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إدارة أولياء الأمور والطلاب المسجلين في النظام',
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

          // Stats
          SliverToBoxAdapter(
            child: parentsAsync.when(
              data: (parents) {
                final parentUsers = parents.where((user) => user.role == UserRole.parent).toList();
                return childrenAsync.when(
                  data: (children) {
                    final totalChildren = children.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'إجمالي أولياء الأمور',
                              '${parentUsers.length}',
                              Icons.family_restroom,
                              AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'أولياء الأمور النشطين',
                              '${parentUsers.where((parent) => parent.status == 'active').length}',
                              Icons.check_circle,
                              AppTheme.successColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'إجمالي الطلاب',
                              '$totalChildren',
                              Icons.school,
                              AppTheme.infoColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const LoadingIndicator(),
                  error: (error, stack) => app_error.AsyncErrorWidget(
                    error: error,
                    stackTrace: stack,
                    onRetry: () => ref.refresh(childrenControllerProvider),
                  ),
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => app_error.AsyncErrorWidget(
                error: error,
                stackTrace: stack,
                onRetry: () => ref.refresh(usersControllerProvider),
              ),
            ),
          ),

          // Parents List
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
                        'قائمة أولياء الأمور',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddParentDialog(),
                        icon: const Icon(Icons.person_add),
                        label: const Text('إضافة ولي أمر'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Parents List
                  parentsAsync.when(
                    data: (parents) {
                      final parentUsers = parents.where((user) => user.role == UserRole.parent).toList();
                      return parentUsers.isEmpty
                          ? _buildEmptyState()
                          : Column(
                              children: parentUsers.map((parent) => _buildParentCard(parent, childrenAsync)).toList(),
                            );
                    },
                    loading: () => const LoadingIndicator(),
                    error: (error, stack) => app_error.AsyncErrorWidget(
                      error: error,
                      stackTrace: stack,
                      onRetry: () => ref.refresh(usersControllerProvider),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
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

  Widget _buildParentCard(AppUser parent, AsyncValue<List<ChildModel>> childrenAsync) {
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
                        parent.name.split(' ').take(2).map((n) => n[0]).join(''),
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
                          parent.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${parent.username}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          parent.email??"",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, parent),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('تعديل'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'children',
                        child: ListTile(
                          leading: Icon(Icons.child_care),
                          title: Text('إدارة الطلاب'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'contact',
                        child: ListTile(
                          leading: Icon(Icons.phone),
                          title: Text('معلومات الاتصال'),
                        ),
                      ),
                      PopupMenuItem(
                        value: parent.status == 'active' ? 'deactivate' : 'activate',
                        child: ListTile(
                          leading: Icon(
                            parent.status == 'active' ? Icons.pause : Icons.play_arrow,
                            color: parent.status == 'active' ? Colors.orange : Colors.green,
                          ),
                          title: Text(
                            parent.status == 'active' ? 'إيقاف' : 'تفعيل',
                            style: TextStyle(
                              color: parent.status == 'active' ? Colors.orange : Colors.green,
                            ),
                          ),
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

              // Contact Information
              Row(
                children: [
                  Expanded(
                    child: _buildContactInfo(
                      'رقم الهاتف',
                      parent.phone ?? 'غير محدد',
                      Icons.phone,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildContactInfo(
                      'الحالة',
                      parent.status == 'active' ? 'نشط' : 'غير نشط',
                      Icons.circle,
                      parent.status == 'active' ? AppTheme.successColor : AppTheme.warningColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Children Information
              childrenAsync.when(
                data: (children) {
                  final parentChildren = children.where((child) => child.parentId == parent.id).toList();
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.child_care,
                              color: AppTheme.infoColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'الطلاب (${parentChildren.length})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (parentChildren.isEmpty)
                          Text(
                            'لا يوجد طلاب مسجلين',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: parentChildren.map((child) => _buildChildChip(child)).toList(),
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('خطأ في تحميل الطلاب: $error'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildChip(ChildModel child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: child.isApproved ? AppTheme.successColor.withOpacity(0.1) : AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: child.isApproved ? AppTheme.successColor : AppTheme.warningColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            child.isApproved ? Icons.check_circle : Icons.pending,
            size: 16,
            color: child.isApproved ? AppTheme.successColor : AppTheme.warningColor,
          ),
          const SizedBox(width: 4),
          Text(
            child.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: child.isApproved ? AppTheme.successColor : AppTheme.warningColor,
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
            Icons.family_restroom_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد أولياء أمور مسجلين',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة أولياء الأمور لإدارة الطلاب',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, AppUser parent) {
    switch (action) {
      case 'edit':
        _showEditParentDialog(parent);
        break;
      case 'children':
        _showChildrenDialog(parent);
        break;
      case 'contact':
        _showContactInfo(parent);
        break;
      case 'activate':
      case 'deactivate':
        _toggleParentStatus(parent);
        break;
      case 'delete':
        _showDeleteConfirmation(parent);
        break;
    }
  }

  void _showAddParentDialog() {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة ولي أمر جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
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
            onPressed: () {
              // This would be handled by AuthService for user registration
              Navigator.pop(context);
              QuickAlert.show(
                context: context,
                type: QuickAlertType.info,
                text: 'سيتم إضافة ولي الأمر من خلال نظام التسجيل',
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditParentDialog(AppUser parent) {
    final nameController = TextEditingController(text: parent.name);
    final emailController = TextEditingController(text: parent.email);
    final phoneController = TextEditingController(text: parent.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل ولي الأمر'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
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
              try {
                await ref.read(usersControllerProvider.notifier).updateUserData(
                  parent.id,
                  {
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                  },
                );
                Navigator.pop(context);
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success,
                  text: 'تم تحديث بيانات ولي الأمر بنجاح',
                );
              } catch (e) {
                Navigator.pop(context);
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  text: 'حدث خطأ أثناء تحديث البيانات',
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showChildrenDialog(AppUser parent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('طلاب ${parent.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer(
            builder: (context, ref, child) {
              final childrenAsync = ref.watch(childrenControllerProvider);
              return childrenAsync.when(
                data: (children) {
                  final parentChildren = children.where((child) => child.parentId == parent.id).toList();
                  if (parentChildren.isEmpty) {
                    return const Center(
                      child: Text('لا يوجد طلاب مسجلين لهذا ولي الأمر'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: parentChildren.length,
                    itemBuilder: (context, index) {
                      final child = parentChildren[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(child.name[0]),
                        ),
                        title: Text(child.name),
                        subtitle: Text('العمر: ${child.age} سنة'),
                        trailing: Icon(
                          child.isApproved ? Icons.check_circle : Icons.pending,
                          color: child.isApproved ? AppTheme.successColor : AppTheme.warningColor,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('خطأ: $error')),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showContactInfo(AppUser parent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات الاتصال'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactRow('الاسم', parent.name),
            _buildContactRow('اسم المستخدم', '@${parent.username}'),
            _buildContactRow('البريد الإلكتروني', parent.email??""),
            _buildContactRow('رقم الهاتف', parent.phone ?? 'غير محدد'),
            _buildContactRow('الحالة', parent.status == 'active' ? 'نشط' : 'غير نشط'),
            _buildContactRow('تاريخ التسجيل', parent.createdAt.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _toggleParentStatus(AppUser parent) {
    final newStatus = parent.status == 'active' ? 'inactive' : 'active';
    final statusText = newStatus == 'active' ? 'تفعيل' : 'إيقاف';
    
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: 'هل أنت متأكد من $statusText ولي الأمر؟',
      confirmBtnText: 'نعم',
      cancelBtnText: 'لا',
      onConfirmBtnTap: () async {
        try {
          await ref.read(usersControllerProvider.notifier).updateUserData(
            parent.id,
            {'status': newStatus},
          );
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'تم $statusText ولي الأمر بنجاح',
          );
        } catch (e) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: 'حدث خطأ أثناء $statusText ولي الأمر',
          );
        }
      },
    );
  }

  void _showDeleteConfirmation(AppUser parent) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: 'هل أنت متأكد من حذف ولي الأمر؟\nلا يمكن التراجع عن هذا الإجراء.',
      confirmBtnText: 'حذف',
      cancelBtnText: 'إلغاء',
      onConfirmBtnTap: () async {
        try {
          await ref.read(usersControllerProvider.notifier).deleteUser(parent.id);
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'تم حذف ولي الأمر بنجاح',
          );
        } catch (e) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: 'حدث خطأ أثناء حذف ولي الأمر',
          );
        }
      },
    );
  }
}
