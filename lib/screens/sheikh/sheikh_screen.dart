import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sheikh_dashboard_screen.dart';

class SheikhScreen extends ConsumerStatefulWidget {
  const SheikhScreen({super.key});

  @override
  ConsumerState<SheikhScreen> createState() => _SheikhScreenState();
}

class _SheikhScreenState extends ConsumerState<SheikhScreen> {
  @override
  Widget build(BuildContext context) {
    return const SheikhDashboardScreen();
  }
}
