import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/utils/constants.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'home_page.dart';
import 'students_page.dart';
import 'tasks_page.dart';

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
        //drawer: _buildDrawer(authState),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppUser? authState) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.surfaceColor,
      shadowColor: Colors.black12,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => _showLogoutDialog(),
        icon: Icon(Icons.logout_outlined),
      ),
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
            borderRadius: BorderRadius.circular(100),
            child: Image.asset('assets/icons/logo.png', fit: BoxFit.fill),
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'الطلاب'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'المهام'),
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
