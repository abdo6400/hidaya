import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/sheikhs_controller.dart';
import 'package:hidaya/controllers/category_controller.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/models/category_model.dart';
import 'package:hidaya/services/auth_service.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:quickalert/quickalert.dart';

import '../../providers/firebase_providers.dart';

class SheikhsScreen extends ConsumerStatefulWidget {
  const SheikhsScreen({super.key});

  @override
  ConsumerState<SheikhsScreen> createState() => _SheikhsScreenState();
}

class _SheikhsScreenState extends ConsumerState<SheikhsScreen> {
  @override
  Widget build(BuildContext context) {
    final sheikhsAsync = ref.watch(sheikhsControllerProvider);
    final categoriesAsync = ref.watch(categoryControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: sheikhsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, stack) =>
            app_error.AppErrorWidget(message: error.toString()),
        data: (sheikhs) {
          return CustomScrollView(
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
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'إدارة المحفظين',
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
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي المحفظين',
                          '${sheikhs.length}',
                          Icons.person,
                          AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'المحفظين النشطين',
                          '${sheikhs.where((sheikh) => sheikh.status == 'active').length}',
                          Icons.check_circle,
                          AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'المحفظين المعلقين',
                          '${sheikhs.where((sheikh) => sheikh.status == 'blocked').length}',
                          Icons.pause_circle,
                          AppTheme.warningColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sheikhs List
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
                            'قائمة المحفظين',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddSheikhDialog(),
                            icon: const Icon(Icons.person_add),
                            label: const Text('إضافة محفظ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (sheikhs.isEmpty)
                        _buildEmptyState()
                      else
                        ...sheikhs
                            .map(
                              (sheikh) =>
                                  _buildSheikhCard(sheikh, categoriesAsync),
                            )
                            .toList(),
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
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد محفظين',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على "إضافة محفظ" لإضافة محفظ جديد',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
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

  Widget _buildSheikhCard(
    AppUser sheikh,
    AsyncValue<List<CategoryModel>> categoriesAsync,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        margin: const EdgeInsets.all(2),
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
                        sheikh.name
                            .split(' ')
                            .take(2)
                            .map((n) => n.isNotEmpty ? n[0] : '')
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
                          sheikh.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${sheikh.username}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sheikh.email ?? 'لا يوجد بريد إلكتروني',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, sheikh),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('تعديل'),
                        ),
                      ),
                      PopupMenuItem(
                        value: sheikh.status == 'active'
                            ? 'deactivate'
                            : 'activate',
                        child: ListTile(
                          leading: Icon(
                            sheikh.status == 'active'
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: sheikh.status == 'active'
                                ? Colors.orange
                                : Colors.green,
                          ),
                          title: Text(
                            sheikh.status == 'active' ? 'إيقاف' : 'تفعيل',
                            style: TextStyle(
                              color: sheikh.status == 'active'
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

              const SizedBox(height: 15),

              // Contact Info
              Row(
                children: [
                  Expanded(
                    child: _buildSheikhStat(
                      'رقم الهاتف',
                      sheikh.phone ?? 'غير متوفر',
                      Icons.phone,
                      AppTheme.infoColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSheikhStat(
                      'الحالة',
                      sheikh.status == 'active' ? 'نشط' : 'معلق',
                      sheikh.status == 'active'
                          ? Icons.check_circle
                          : Icons.pause_circle,
                      sheikh.status == 'active'
                          ? AppTheme.successColor
                          : Colors.grey,
                    ),
                  ),
                ],
              ),

              if (sheikh.createdAt != null) ...[
                const SizedBox(height: 10),
                Text(
                  'تاريخ الانضمام: ${_formatDate(sheikh.createdAt!)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheikhStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action, AppUser sheikh) {
    switch (action) {
      case 'edit':
        _showEditSheikhDialog(sheikh);
        break;
      case 'assign':
        _showAssignCategoriesDialog(sheikh);
        break;
      case 'activate':
      case 'deactivate':
        _toggleSheikhStatus(sheikh);
        break;
      case 'delete':
        _showDeleteConfirmation(sheikh);
        break;
    }
  }

  void _showAddSheikhDialog() {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إضافة محفظ جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المحفظ',
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
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
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
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
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
                  await _addSheikh(
                    nameController.text,
                    usernameController.text,
                    passwordController.text,
                    phoneController.text,
                    emailController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheikhDialog(AppUser sheikh) {
    final nameController = TextEditingController(text: sheikh.name);
    final phoneController = TextEditingController(text: sheikh.phone);
    final emailController = TextEditingController(text: sheikh.email);

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل بيانات المحفظ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المحفظ',
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
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await _editSheikh(
                    sheikh.id,
                    nameController.text,
                    phoneController.text,
                    emailController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignCategoriesDialog(AppUser sheikh) {
    // This would be implemented when we have category assignments
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 تعيين الفئات - سيتم تنفيذها قريباً'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  Future<void> _addSheikh(
    String name,
    String username,
    String password,
    String phone,
    String email,
  ) async {
    try {
      final authService = AuthService();
      await authService.register(
        username: username,
        password: password,
        name: name,
        role: UserRole.sheikh,
        phone: phone,
        email: email,
        status: 'active',
      );

      // Refresh the sheikhs list
      ref.read(sheikhsControllerProvider.notifier).loadItems();
      ref.refresh(dashboardStatsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة المحفظ "$name" بنجاح'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إضافة المحفظ: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _editSheikh(
    String id,
    String name,
    String phone,
    String email,
  ) async {
    try {
      final sheikhsController = ref.read(sheikhsControllerProvider.notifier);

      // Get the current sheikh data
      final currentSheikh = await sheikhsController.getSheikhById(id);
      if (currentSheikh == null) {
        throw Exception('المحفظ غير موجود');
      }

      // Create updated sheikh
      final updatedSheikh = currentSheikh.copyWith(
        name: name,
        phone: phone,
        email: email,
      );

      await sheikhsController.updateSheikh(updatedSheikh);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تعديل بيانات المحفظ "$name" بنجاح'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تعديل بيانات المحفظ: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _toggleSheikhStatus(AppUser sheikh) async {
    try {
      final sheikhsController = ref.read(sheikhsControllerProvider.notifier);
      final newStatus = sheikh.status == 'active' ? 'blocked' : 'active';
      await sheikhsController.updateSheikhStatus(sheikh.id, newStatus);

      final status = newStatus == 'active' ? 'تفعيل' : 'إيقاف';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم $status المحفظ "${sheikh.name}" بنجاح'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تغيير حالة المحفظ: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showDeleteConfirmation(AppUser sheikh) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'حذف المحفظ',
      text:
          'هل أنت متأكد من حذف المحفظ "${sheikh.name}"؟ لا يمكن التراجع عن هذا الإجراء.',
      confirmBtnText: 'حذف',
      cancelBtnText: 'إلغاء',
      confirmBtnColor: AppTheme.errorColor,
      showCancelBtn: true,
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        await _deleteSheikh(sheikh.id);
      },
    );
  }

  Future<void> _deleteSheikh(String id) async {
    try {
      final sheikhsController = ref.read(sheikhsControllerProvider.notifier);
      await sheikhsController.deleteSheikh(id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف المحفظ بنجاح'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حذف المحفظ: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
