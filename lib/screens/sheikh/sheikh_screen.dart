import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/utils/constants.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/students_page.dart';
import 'pages/tasks_page.dart';


class SheikhScreen extends ConsumerStatefulWidget {
  const SheikhScreen({super.key});

  @override
  ConsumerState<SheikhScreen> createState() => _SheikhScreenState();
}

class _SheikhScreenState extends ConsumerState<SheikhScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: _buildAppBar(authState),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
        drawer: _buildDrawer(authState),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppUser? authState) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.surfaceColor,
      shadowColor: Colors.black12,
      centerTitle: true,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          _getCurrentTitle(),
          key: ValueKey(_currentIndex),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset(
              'assets/icons/logo.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }

  Widget _buildDrawer(AppUser? authState) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لوحة المحفظ',
                    style: AppTheme.islamicTitleStyle.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            
            // User Info
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow('اسم المستخدم:', authState?.username ?? ""),
                  const SizedBox(height: 8),
                  _buildInfoRow('الرقم:', authState?.phone ?? ""),
                  const SizedBox(height: 8),
                  _buildInfoRow('الدور:', AppConstants.sheikhRole),
                ],
              ),
            ),
            
            // Menu Items
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDrawerItem(
                      icon: Icons.settings,
                      title: AppConstants.settings,
                      onTap: () => _navigateToSettings(),
                    ),
                    _buildDrawerItem(
                      icon: Icons.help,
                      title: 'المساعدة',
                      onTap: () => _navigateToHelp(),
                    ),
                    _buildDrawerItem(
                      icon: Icons.info,
                      title: 'حول التطبيق',
                      onTap: () => _navigateToAbout(),
                    ),
                    const Divider(height: 32),
                    _buildDrawerItem(
                      icon: Icons.logout,
                      title: 'تسجيل الخروج',
                      onTap: () => _showLogoutDialog(),
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorColor : AppTheme.primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isDestructive ? AppTheme.errorColor : AppTheme.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildBody() {
    final authState = ref.watch(authControllerProvider);
    final sheikhId = authState?.id;
    if (sheikhId == null) return const SizedBox.shrink();
    switch (_currentIndex) {
      case 0:
        return SheikhHomePage(sheikhId: sheikhId);
      case 1:
        return SheikhStudentsPage(sheikhId: sheikhId);
      case 2:
        return SheikhTasksPage(sheikhId: sheikhId);
      default:
        return SheikhHomePage(sheikhId: sheikhId);
    }
  }

  
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'الطلاب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'المهام',
          ),
        ],
      ),
    );
  }

  String _getCurrentTitle() {
    switch (_currentIndex) {
      case 0:
        return 'الرئيسية';
      case 1:
        return 'الطلاب';
      case 2:
        return 'المهام';
      default:
        return 'الرئيسية';
    }
  }

  void _navigateToSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 شاشة الإعدادات - سيتم تنفيذها قريباً'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _navigateToHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 شاشة المساعدة - سيتم تنفيذها قريباً'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _navigateToAbout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 شاشة حول التطبيق - سيتم تنفيذها قريباً'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
