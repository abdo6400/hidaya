import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/constants.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:quickalert/quickalert.dart';

class SheikhsScreen extends ConsumerStatefulWidget {
  const SheikhsScreen({super.key});

  @override
  ConsumerState<SheikhsScreen> createState() => _SheikhsScreenState();
}

class _SheikhsScreenState extends ConsumerState<SheikhsScreen> {
  final List<Map<String, dynamic>> _sheikhs = [
    {
      'id': '1',
      'name': 'الشيخ أحمد محمد',
      'username': 'ahmed_mohamed',
      'phone': '+201234567890',
      'email': 'ahmed@hidaya.com',
      'categories': ['حفظ القرآن الكريم', 'التلاوة والتجويد'],
      'workingDays': ['الأحد', 'الثلاثاء', 'الخميس'],
      'studentCount': 25,
      'isActive': true,
      'joinDate': '2024-01-15',
    },
    {
      'id': '2',
      'name': 'الشيخ محمد علي',
      'username': 'mohamed_ali',
      'phone': '+201234567891',
      'email': 'mohamed@hidaya.com',
      'categories': ['السلوك والأخلاق'],
      'workingDays': ['الاثنين', 'الأربعاء'],
      'studentCount': 18,
      'isActive': true,
      'joinDate': '2024-02-01',
    },
    {
      'id': '3',
      'name': 'الشيخ علي حسن',
      'username': 'ali_hassan',
      'phone': '+201234567892',
      'email': 'ali@hidaya.com',
      'categories': ['الحديث الشريف', 'حفظ القرآن الكريم'],
      'workingDays': ['السبت', 'الأحد', 'الثلاثاء'],
      'studentCount': 32,
      'isActive': false,
      'joinDate': '2023-12-10',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                          Icons.person,
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
                              'إدارة المحفظين',
                              style: AppTheme.islamicTitleStyle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إضافة وإدارة المحفظين وتعيينهم للفئات التعليمية',
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
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي المحفظين',
                      '${_sheikhs.length}',
                      Icons.person,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'المحفظين النشطين',
                      '${_sheikhs.where((sheikh) => sheikh['isActive']).length}',
                      Icons.check_circle,
                      AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي الطلاب',
                      '${_sheikhs.fold<int>(0, (sum, sheikh) => sum + (sheikh['studentCount'] as int))}',
                      Icons.school,
                      AppTheme.infoColor,
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                  ..._sheikhs.map((sheikh) => _buildSheikhCard(sheikh)).toList(),
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

  Widget _buildSheikhCard(Map<String, dynamic> sheikh) {
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
                        sheikh['name'].split(' ').take(2).map((n) => n[0]).join(''),
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
                          sheikh['name'],
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${sheikh['username']}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sheikh['email'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
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
                      const PopupMenuItem(
                        value: 'assign',
                        child: ListTile(
                          leading: Icon(Icons.assignment),
                          title: Text('تعيين فئات'),
                        ),
                      ),
                      PopupMenuItem(
                        value: sheikh['isActive'] ? 'deactivate' : 'activate',
                        child: ListTile(
                          leading: Icon(
                            sheikh['isActive'] ? Icons.pause : Icons.play_arrow,
                            color: sheikh['isActive'] ? Colors.orange : Colors.green,
                          ),
                          title: Text(
                            sheikh['isActive'] ? 'إيقاف' : 'تفعيل',
                            style: TextStyle(
                              color: sheikh['isActive'] ? Colors.orange : Colors.green,
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

              // Categories
              Text(
                'الفئات التعليمية:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (sheikh['categories'] as List<String>).map((category) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Working Days
              Text(
                'أيام العمل:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (sheikh['workingDays'] as List<String>).map((day) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildSheikhStat(
                      'الطلاب',
                      '${sheikh['studentCount']}',
                      Icons.school,
                      AppTheme.infoColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSheikhStat(
                      'الفئات',
                      '${(sheikh['categories'] as List<String>).length}',
                      Icons.category,
                      AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSheikhStat(
                      'الحالة',
                      sheikh['isActive'] ? 'نشط' : 'غير نشط',
                      sheikh['isActive'] ? Icons.check_circle : Icons.pause_circle,
                      sheikh['isActive'] ? AppTheme.successColor : Colors.grey,
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

  Widget _buildSheikhStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
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

  void _handleMenuAction(String action, Map<String, dynamic> sheikh) {
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () {
              if (nameController.text.isNotEmpty && usernameController.text.isNotEmpty) {
                _addSheikh(
                  nameController.text,
                  usernameController.text,
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
    );
  }

  void _showEditSheikhDialog(Map<String, dynamic> sheikh) {
    final nameController = TextEditingController(text: sheikh['name']);
    final phoneController = TextEditingController(text: sheikh['phone']);
    final emailController = TextEditingController(text: sheikh['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _editSheikh(
                  sheikh['id'],
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
    );
  }

  void _showAssignCategoriesDialog(Map<String, dynamic> sheikh) {
    final List<String> allCategories = [
      'حفظ القرآن الكريم',
      'التلاوة والتجويد',
      'السلوك والأخلاق',
      'الحديث الشريف',
    ];

    List<String> selectedCategories = List.from(sheikh['categories']);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعيين الفئات التعليمية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: allCategories.map((category) {
              return CheckboxListTile(
                title: Text(category),
                value: selectedCategories.contains(category),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedCategories.add(category);
                    } else {
                      selectedCategories.remove(category);
                    }
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _assignCategories(sheikh['id'], selectedCategories);
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _addSheikh(String name, String username, String phone, String email) {
    final newSheikh = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'username': username,
      'phone': phone,
      'email': email,
      'categories': [],
      'workingDays': [],
      'studentCount': 0,
      'isActive': true,
      'joinDate': DateTime.now().toIso8601String().split('T')[0],
    };

    setState(() {
      _sheikhs.add(newSheikh);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة المحفظ "$name" بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _editSheikh(String id, String name, String phone, String email) {
    setState(() {
      final index = _sheikhs.indexWhere((sheikh) => sheikh['id'] == id);
      if (index != -1) {
        _sheikhs[index]['name'] = name;
        _sheikhs[index]['phone'] = phone;
        _sheikhs[index]['email'] = email;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تعديل بيانات المحفظ "$name" بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _assignCategories(String id, List<String> categories) {
    setState(() {
      final index = _sheikhs.indexWhere((sheikh) => sheikh['id'] == id);
      if (index != -1) {
        _sheikhs[index]['categories'] = categories;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تعيين الفئات بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _toggleSheikhStatus(Map<String, dynamic> sheikh) {
    setState(() {
      sheikh['isActive'] = !sheikh['isActive'];
    });

    final status = sheikh['isActive'] ? 'تفعيل' : 'إيقاف';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم $status المحفظ "${sheikh['name']}" بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> sheikh) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'حذف المحفظ',
      text: 'هل أنت متأكد من حذف المحفظ "${sheikh['name']}"؟ لا يمكن التراجع عن هذا الإجراء.',
      confirmBtnText: 'حذف',
      cancelBtnText: 'إلغاء',
      confirmBtnColor: AppTheme.errorColor,
      showCancelBtn: true,
      onConfirmBtnTap: () {
        Navigator.pop(context);
        _deleteSheikh(sheikh['id']);
      },
    );
  }

  void _deleteSheikh(String id) {
    setState(() {
      _sheikhs.removeWhere((sheikh) => sheikh['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف المحفظ بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
