import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'constants/index.dart';
import 'bloc/index.dart';
import 'services/index.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/students/students_screen.dart';
import 'screens/sheikhs/sheikhs_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/reports/reports_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    DevicePreview(
      enabled: kDebugMode, // Set to true for device preview
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(
            dashboardRepository: DashboardRepository(),
          ),
        ),
        BlocProvider<StudentsBloc>(
          create: (context) => StudentsBloc(
            studentRepository: StudentRepository(),
          ),
        ),
        BlocProvider<TasksBloc>(
          create: (context) => TasksBloc(
            taskRepository: TaskRepository(),
          ),
        ),
        BlocProvider<ResultsBloc>(
          create: (context) => ResultsBloc(
            resultRepository: ResultRepository(),
          ),
        ),
        BlocProvider<SheikhsBloc>(
          create: (context) => SheikhsBloc(
            sheikhRepository: SheikhRepository(),
          ),
        ),
       
      ],
      child: MaterialApp.router(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'SA'), // Arabic
          Locale('en', 'US'), // English
        ],
        locale: const Locale('ar', 'SA'),
        routerConfig: _router,
        builder: DevicePreview.appBuilder,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/students',
          builder: (context, state) => const StudentsScreen(),
        ),
        GoRoute(
          path: '/sheikhs',
          builder: (context, state) => const SheikhsScreen(),
        ),
        // GoRoute(
        //   path: '/groups',
        //   builder: (context, state) => const GroupsScreen(),
        // ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        // GoRoute(
        //   path: '/settings',
        //   builder: (context, state) => const SettingsScreen(),
        // ),
      ],
    ),
  ],
);

class MainNavigationScreen extends StatefulWidget {
  final Widget child;

  const MainNavigationScreen({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: AppStrings.dashboard,
      route: '/dashboard',
    ),
    NavigationItem(
      icon: Icons.school,
      label: AppStrings.students,
      route: '/students',
    ),
    NavigationItem(
      icon: Icons.person,
      label: AppStrings.sheikhs,
      route: '/sheikhs',
    ),
    // NavigationItem(
    //   icon: Icons.groups,
    //   label: AppStrings.groups,
    //   route: '/groups',
    // ),
    NavigationItem(
      icon: Icons.assignment,
      label: AppStrings.tasks,
      route: '/tasks',
    ),
    NavigationItem(
      icon: Icons.analytics,
      label: AppStrings.reports,
      route: '/reports',
    ),
    // NavigationItem(
    //   icon: Icons.settings,
    //   label: 'الإعدادات',
    //   route: '/settings',
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            context.go(_navigationItems[index].route);
          },
          type: BottomNavigationBarType.fixed,
          items: _navigationItems.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}