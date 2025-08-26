import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:hidaya/screens/admin/dashboard_screen.dart';
import 'package:hidaya/screens/admin/parents_screen.dart';
import 'package:quickalert/quickalert.dart';

import 'categories_screen.dart';
import 'sheikhs_screen.dart';
import 'tasks_screen.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          
          appBar: AppBar(
            elevation: 5,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipOval(child: Image.asset('assets/icons/logo.png', width: 50, height: 50)),
              ),
            ],
            centerTitle: true,
            title: Text(
              ["الرئيسية", "المحفظين", "الفئات", "المهام", "الأباء"][_currentIndex],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
          drawer: Drawer(
            child: Column(
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        image: AssetImage('assets/icons/logo.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 10,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('اسم المستخدم: '),
                          Text(
                            authState?.username ?? "",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('الرقم: '),
                          Text(
                            authState?.phone ?? "",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.date_range, size: 24, color: Colors.blue),
                            visualDensity: VisualDensity.compact,
                            title: const Text(
                              "جدول المواعيد",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.logout_outlined, size: 24, color: Colors.red),
                            visualDensity: VisualDensity.compact,
                            title: const Text(
                              'تسجيل الخروج',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                            onTap: () {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.confirm,
                                title: 'تسجيل الخروج',
                                text: 'هل أنت متأكد من تسجيل الخروج؟',
                                confirmBtnText: 'تاكيد',
                                cancelBtnText: 'إلغاء',
                                confirmBtnColor: Theme.of(context).colorScheme.primary,
                                showCancelBtn: true,
                                onConfirmBtnTap: () {
                                  Navigator.pop(context);
                                  ref.read(authControllerProvider.notifier).logout();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              DashboardScreen(),
              SheikhsScreen(),
              CategoriesScreen(),
              TasksScreen(),
              ParentsScreen(),
            ],
          ),
          bottomNavigationBar: ConvexAppBar(
            initialActiveIndex: _currentIndex,
            backgroundColor: Theme.of(context).colorScheme.primary,
            color: Theme.of(context).colorScheme.onPrimary,
            style: TabStyle.react,
            items: [
              TabItem(icon: Icons.dashboard_customize, title: 'الرئيسية'),
              TabItem(icon: Icons.group_add, title: 'المحفظين'),
              TabItem(icon: Icons.category_rounded, title: 'الفئات'),
              TabItem(icon: Icons.task, title: 'المهام'),
              TabItem(icon: Icons.person, title: 'الآباء'),
            ],
            onTap: (int i) {
              setState(() {
                _currentIndex = i;
              });
            },
          ),
        ),
      ),
    );
  }
}
