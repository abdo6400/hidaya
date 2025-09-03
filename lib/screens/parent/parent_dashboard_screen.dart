import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/widgets/custom_bottom_nav_bar.dart';
import 'package:hidaya/screens/parent/tabs/home_tab.dart';
import 'package:hidaya/screens/parent/tabs/children_tab.dart';
import 'package:hidaya/screens/parent/tabs/notifications_tab.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
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
        icon: Icon(Icons.logout),
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
    switch (_currentIndex) {
      case 0:
        return const HomeTab();
      case 1:
        return const ChildrenTab();
      case 2:
        return const NotificationsTab();
      default:
        return const HomeTab();
    }
  }



  Widget _buildBottomNavigationBar() {
    return CustomBottomNavBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavItem(icon: Icons.home, label: 'الرئيسية'),
        BottomNavItem(icon: Icons.child_care, label: 'الأبناء'),
        BottomNavItem(icon: Icons.notifications, label: 'الإشعارات'),
      ],
    );
  }

  String _getCurrentTitle() {
    switch (_currentIndex) {
      case 0:
        return 'الرئيسية';
      case 1:
        return 'الأبناء';
      case 2:
        return 'الإشعارات';
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
              ref.read(authControllerProvider.notifier).logout();
              Navigator.pop(context);
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
