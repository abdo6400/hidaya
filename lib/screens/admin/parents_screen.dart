import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/controllers/users_controller.dart';
import 'package:hidaya/controllers/children_controller.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/services/auth_service.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:quickalert/quickalert.dart';
import 'package:hidaya/providers/firebase_providers.dart';

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
              padding: const EdgeInsets.all(20),
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
                        child: Text(
                          'إدارة أولياء الأمور',
                          style: AppTheme.islamicTitleStyle.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                          ),
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
                final parentUsers = parents.where((user) {
                  return user.role == UserRole.parent;
                }).toList();

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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
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
                      final parentUsers = parents
                          .where((user) => user.role == UserRole.parent)
                          .toList();
                      return parentUsers.isEmpty
                          ? _buildEmptyState()
                          : Column(
                              children: parentUsers
                                  .map(
                                    (parent) =>
                                        _buildParentCard(parent, childrenAsync),
                                  )
                                  .toList(),
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

  Widget _buildStatCard(
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

  Widget _buildParentCard(
    AppUser parent,
    AsyncValue<List<ChildModel>> childrenAsync,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        margin: EdgeInsets.all(2),
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
                        parent.name
                            .split(' ')
                            .take(2)
                            .map((n) => n[0])
                            .join(''),
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${parent.username}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          parent.email ?? "",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
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
                        value: parent.status == 'active'
                            ? 'deactivate'
                            : 'activate',
                        child: ListTile(
                          leading: Icon(
                            parent.status == 'active'
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: parent.status == 'active'
                                ? Colors.orange
                                : Colors.green,
                          ),
                          title: Text(
                            parent.status == 'active' ? 'إيقاف' : 'تفعيل',
                            style: TextStyle(
                              color: parent.status == 'active'
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text(
                            'حذف',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

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
                      parent.status == 'active'
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // Children Information
              childrenAsync.when(
                data: (children) {
                  final parentChildren = children
                      .where((child) => child.parentId == parent.id)
                      .toList();
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (parentChildren.isEmpty)
                          Text(
                            'لا يوجد طلاب مسجلين',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: parentChildren
                                .map((child) => _buildChildChip(child))
                                .toList(),
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

  Widget _buildContactInfo(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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
        color: child.isApproved
            ? AppTheme.successColor.withOpacity(0.1)
            : AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: child.isApproved
              ? AppTheme.successColor
              : AppTheme.warningColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            child.isApproved ? Icons.check_circle : Icons.pending,
            size: 16,
            color: child.isApproved
                ? AppTheme.successColor
                : AppTheme.warningColor,
          ),
          const SizedBox(width: 4),
          Text(
            child.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: child.isApproved
                  ? AppTheme.successColor
                  : AppTheme.warningColor,
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة أولياء الأمور لإدارة الطلاب',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
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
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
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
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    usernameController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  try {
                    // Create parent using AuthService
                    await AuthService().register(
                      username: usernameController.text,
                      password: passwordController.text,
                      name: nameController.text,
                      email: emailController.text.isEmpty
                          ? null
                          : emailController.text,
                      phone: phoneController.text.isEmpty
                          ? null
                          : phoneController.text,
                      status: 'active',
                      role: UserRole.parent,
                    );

                    Navigator.pop(context);

                    // Refresh the parents list
                    ref.refresh(usersControllerProvider);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة ولي الأمر بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ في إضافة ولي الأمر: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى ملء الحقول المطلوبة'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditParentDialog(AppUser parent) {
    final nameController = TextEditingController(text: parent.name);
    final emailController = TextEditingController(text: parent.email);
    final phoneController = TextEditingController(text: parent.phone);

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
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
                  await ref
                      .read(usersControllerProvider.notifier)
                      .updateUserData(parent.id, {
                        'name': nameController.text,
                        'email': emailController.text,
                        'phone': phoneController.text,
                      });
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
      ),
    );
  }

  void _showChildrenDialog(AppUser parent) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            constraints: const BoxConstraints(
              minWidth: 500,
              minHeight: 500,
              maxWidth: 900,
              maxHeight: 700,
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'طلاب ${parent.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: 'إغلاق',
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final childrenAsync = ref.watch(
                          childrenControllerProvider,
                        );
                        return childrenAsync.when(
                          data: (children) {
                            final parentChildren = children
                                .where((child) => child.parentId == parent.id)
                                .toList();
                            if (parentChildren.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لا يوجد طلاب مسجلين لهذا ولي الأمر',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: parentChildren.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final child = parentChildren[index];
                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            child.name[0],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Child info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              child.name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'العمر: ${child.age} سنة',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Icon(
                                                  child.isApproved
                                                      ? Icons.check_circle
                                                      : Icons.pending,
                                                  size: 14,
                                                  color: child.isApproved
                                                      ? AppTheme.successColor
                                                      : AppTheme.warningColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    child.isApproved
                                                        ? 'موافق عليه'
                                                        : 'في انتظار الموافقة',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: child.isApproved
                                                          ? AppTheme
                                                                .successColor
                                                          : AppTheme
                                                                .warningColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Actions
                                      SizedBox(
                                        width:
                                            120, // Fixed width to prevent overflow
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // Edit button
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: IconButton(
                                                onPressed: () =>
                                                    _showEditChildDialog(child),
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 16,
                                                ),
                                                color: AppTheme.primaryColor,
                                                tooltip: 'تعديل',
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            // Approve/Reject button
                                            if (!child.isApproved)
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.successColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: IconButton(
                                                  onPressed: () =>
                                                      _approveChild(child),
                                                  icon: const Icon(
                                                    Icons.check_circle_outline,
                                                    size: 16,
                                                  ),
                                                  color: AppTheme.successColor,
                                                  tooltip: 'موافقة',
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                ),
                                              )
                                            else
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.warningColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: IconButton(
                                                  onPressed: () =>
                                                      _rejectChild(child),
                                                  icon: const Icon(
                                                    Icons.cancel_outlined,
                                                    size: 16,
                                                  ),
                                                  color: AppTheme.warningColor,
                                                  tooltip: 'رفض',
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                ),
                                              ),
                                            const SizedBox(width: 2),
                                            // Delete button
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: AppTheme.errorColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: IconButton(
                                                onPressed: () =>
                                                    _showDeleteChildConfirmation(
                                                      child,
                                                    ),
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 16,
                                                ),
                                                color: AppTheme.errorColor,
                                                tooltip: 'حذف',
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('جاري تحميل الطلاب...'),
                              ],
                            ),
                          ),
                          error: (error, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'خطأ: $error',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Footer actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),

                        label: const Text('إغلاق'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddChildDialog(parent),
                          icon: const Icon(Icons.person_add),
                          label: const Text('إضافة طالب جديد'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContactInfo(AppUser parent) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('معلومات الاتصال'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactRow('الاسم', parent.name),
              _buildContactRow('اسم المستخدم', '@${parent.username}'),
              _buildContactRow('البريد الإلكتروني', parent.email ?? ""),
              _buildContactRow('رقم الهاتف', parent.phone ?? 'غير محدد'),
              _buildContactRow(
                'الحالة',
                parent.status == 'active' ? 'نشط' : 'غير نشط',
              ),
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
          Expanded(child: Text(value)),
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
      title: 'تأكيد الإجراء',
      text: 'هل أنت متأكد من $statusText ولي الأمر؟',
      confirmBtnText: 'نعم',
      cancelBtnText: 'لا',
      onCancelBtnTap: () => Navigator.pop(context),
      onConfirmBtnTap: () async {
        try {
          await ref.read(usersControllerProvider.notifier).updateUserData(
            parent.id,
            {'status': newStatus},
          );
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم $statusText ولي الأمر بنجاح'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء $statusText ولي الأمر'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
    );
  }

  void _showDeleteConfirmation(AppUser parent) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'تأكيد الحذف',
      text: 'هل أنت متأكد من حذف ولي الأمر؟\nلا يمكن التراجع عن هذا الإجراء.',
      confirmBtnText: 'حذف',
      cancelBtnText: 'إلغاء',
      onCancelBtnTap: () => Navigator.pop(context),
      onConfirmBtnTap: () async {
        try {
          await AuthService().deleteAccount(userId: parent.id);
          ref.read(childrenControllerProvider.notifier).deleteChild(parent.id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف ولي الأمر بنجاح'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء حذف ولي الأمر'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
    );
  }

  void _approveChild(ChildModel child) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'تأكيد الموافقة',
      text: 'هل أنت متأكد من الموافقة على الطالب ${child.name}؟',
      confirmBtnText: 'نعم',
      cancelBtnText: 'لا',
      onCancelBtnTap: () => Navigator.pop(context),
      onConfirmBtnTap: () async {
        try {
          // Update child approval status - create new child with updated approval
          final updatedChild = ChildModel(
            id: child.id,
            name: child.name,
            age: child.age,
            parentId: child.parentId,
            isApproved: true,
            createdBy: child.createdBy,
            createdAt: child.createdAt,
            categoryId: child.categoryId,
            sheikhId: child.sheikhId,
            assignedAt: child.assignedAt,
          );
          await ref
              .read(childrenControllerProvider.notifier)
              .updateItem(updatedChild);

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم الموافقة على الطالب بنجاح'),
              backgroundColor: AppTheme.successColor,
            ),
          );

          // Refresh all related providers to update stats across screens
          ref.refresh(childrenControllerProvider);
          ref.refresh(dashboardStatsProvider);
          ref.refresh(usersControllerProvider);
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء الموافقة على الطالب'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
    );
  }

  void _showAddChildDialog(AppUser parent) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('إضافة طالب لولي الأمر ${parent.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الطالب',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'العمر',
                    border: OutlineInputBorder(),
                    helperText: 'أدخل العمر بالأرقام',
                  ),
                  keyboardType: TextInputType.number,
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
                if (nameController.text.isNotEmpty &&
                    ageController.text.isNotEmpty) {
                  try {
                    final age = int.tryParse(ageController.text);
                    if (age == null || age <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى إدخال عمر صحيح'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final child = ChildModel(
                      id: '',
                      name: "${nameController.text} ${parent.name}",
                      age: age.toString(),
                      parentId: parent.id,
                      isApproved: true, // Auto-approve when added by admin
                      createdBy: 'admin', // Admin is creating this child
                    );

                    await ref
                        .read(childrenControllerProvider.notifier)
                        .addItem(child);
                    Navigator.pop(context);

                    // Refresh all related providers to update stats across screens
                    ref.refresh(childrenControllerProvider);
                    ref.refresh(dashboardStatsProvider);
                    ref.refresh(usersControllerProvider);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة الطالب بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ في إضافة الطالب: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى ملء الحقول المطلوبة'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _rejectChild(ChildModel child) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'تأكيد الرفض',
      text: 'هل أنت متأكد من رفض الطالب ${child.name}؟',
      confirmBtnText: 'نعم',
      cancelBtnText: 'لا',
      onCancelBtnTap: () => Navigator.pop(context),
      onConfirmBtnTap: () async {
        try {
          // Update child approval status to rejected
          final updatedChild = ChildModel(
            id: child.id,
            name: child.name,
            age: child.age,
            parentId: child.parentId,
            isApproved: false,
            createdBy: child.createdBy,
            createdAt: child.createdAt,
            categoryId: child.categoryId,
            sheikhId: child.sheikhId,
            assignedAt: child.assignedAt,
          );
          await ref
              .read(childrenControllerProvider.notifier)
              .updateItem(updatedChild);

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم رفض الطالب ${child.name}'),
              backgroundColor: AppTheme.warningColor,
            ),
          );

          // Refresh all related providers to update stats across screens
          ref.refresh(childrenControllerProvider);
          ref.refresh(dashboardStatsProvider);
          ref.refresh(usersControllerProvider);
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء رفض الطالب'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
    );
  }

  void _showEditChildDialog(ChildModel child) {
    final nameController = TextEditingController(text: child.name);
    final ageController = TextEditingController(text: child.age);

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تعديل بيانات الطالب ${child.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الطالب',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'العمر',
                    border: OutlineInputBorder(),
                    helperText: 'أدخل العمر بالأرقام',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'حالة الموافقة:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: child.isApproved,
                      onChanged: (value) {
                        // This will be handled when saving
                      },
                      activeColor: AppTheme.successColor,
                    ),
                    Text(
                      child.isApproved ? 'موافق' : 'غير موافق',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
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
                if (nameController.text.isNotEmpty &&
                    ageController.text.isNotEmpty) {
                  try {
                    final age = int.tryParse(ageController.text);
                    if (age == null || age <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى إدخال عمر صحيح'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final updatedChild = ChildModel(
                      id: child.id,
                      name: nameController.text,
                      age: age.toString(),
                      parentId: child.parentId,
                      isApproved: child.isApproved,
                      createdBy: child.createdBy,
                      createdAt: child.createdAt,
                      categoryId: child.categoryId,
                      sheikhId: child.sheikhId,
                      assignedAt: child.assignedAt,
                    );

                    await ref
                        .read(childrenControllerProvider.notifier)
                        .updateItem(updatedChild);
                    Navigator.pop(context);

                    // Refresh all related providers to update stats across screens
                    ref.refresh(childrenControllerProvider);
                    ref.refresh(dashboardStatsProvider);
                    ref.refresh(usersControllerProvider);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث بيانات الطالب بنجاح'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ في تحديث بيانات الطالب: $e'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى ملء الحقول المطلوبة'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteChildConfirmation(ChildModel child) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'تأكيد الحذف',
      text:
          'هل أنت متأكد من حذف الطالب ${child.name}؟\nلا يمكن التراجع عن هذا الإجراء.',
      confirmBtnText: 'حذف',
      cancelBtnText: 'إلغاء',
      onCancelBtnTap: () => Navigator.pop(context),
      onConfirmBtnTap: () async {
        try {
          await ref
              .read(childrenControllerProvider.notifier)
              .deleteItem(child.id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف الطالب ${child.name} بنجاح'),
              backgroundColor: AppTheme.successColor,
            ),
          );

          // Refresh all related providers to update stats across screens
          ref.refresh(childrenControllerProvider);
          ref.refresh(dashboardStatsProvider);
          ref.refresh(usersControllerProvider);
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء حذف الطالب'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
    );
  }
}
