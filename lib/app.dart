import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/screens/admin/admin_screen.dart';
import 'package:hidaya/screens/auth/auth_screen.dart';
import 'package:hidaya/screens/sheikh/sheikh_screen.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/utils/constants.dart';
import 'package:hidaya/widgets/loading_indicator.dart';

import 'screens/parent/parent_dashboard_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      theme: AppTheme.lightTheme,
      home: _buildHomeScreen(authController, authState),
    );
  }

  Widget _buildHomeScreen(AuthController authController, AppUser? authState) {
    // Show loading screen while auth is initializing
    if (!authController.isInitialized) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    'assets/icons/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.mosque,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppConstants.appTitle,
                style: AppTheme.islamicTitleStyle.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 24),
              const LoadingIndicator(),
            ],
          ),
        ),
      );
    }

    // Show auth screen if no user is logged in
    if (authState == null) {
      return const AuthScreen();
    }

    // Show appropriate dashboard based on user role
    return _getHomeScreen(authState);
  }

  Widget _getHomeScreen(AppUser user) {
    switch (user.role) {
      case UserRole.parent:
        return const ParentDashboardScreen();
      case UserRole.sheikh:
        return const SheikhScreen();
      case UserRole.admin:
        return const AdminScreen();
    }
  }
}
