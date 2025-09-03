import 'package:flutter/material.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('الإشعارات', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text('لا توجد إشعارات جديدة'),
        ],
      ),
    );
  }
}
