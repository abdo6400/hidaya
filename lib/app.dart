import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/screens/admin/admin_screen.dart';
import 'package:hidaya/screens/auth/auth_screen.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/utils/constants.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      theme: AppTheme.lightTheme,
      home: authState == null ? const AuthScreen() : _getHomeScreen(authState, ref),
    );
  }

  Widget _getHomeScreen(AppUser user, WidgetRef ref) {
    switch (user.role) {
      case UserRole.parent:
        return Scaffold(
          appBar: AppBar(
            title: Text('Parent Home'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout();
              },
            ),
          ),
          body: Center(child: Text('Parent Home')),
        );
      case UserRole.sheikh:
        return Scaffold(
          appBar: AppBar(
            title: Text('Sheikh Home'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout();
              },
            ),
          ),
          body: Center(child: Text('Sheikh Home')),
        );
      case UserRole.admin:
        return const AdminScreen();
    }
  }
}
