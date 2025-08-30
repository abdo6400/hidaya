import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'sheikh')
            .count()
            .get(),
        FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'parent')
            .count()
            .get(),
        FirebaseFirestore.instance.collection('categories').count().get(),
        FirebaseFirestore.instance.collection('tasks').count().get(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error}'));
        }
        final data = snapshot.data as List<AggregateQuerySnapshot>;
        final sheikhs = data[0].count;
        final parents = data[1].count;
        final categories = data[2].count;
        final tasks = data[3].count;

        return GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
          padding: const EdgeInsets.all(16),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _StatCard(
              icon: Icons.group,
              label: 'المحفظون',
              value: sheikhs ?? 0,
            ),
            _StatCard(
              icon: Icons.family_restroom,
              label: 'أولياء الأمور',
              value: parents ?? 0,
            ),
            _StatCard(
              icon: Icons.category,
              label: 'التصنيفات',
              value: categories ?? 0,
            ),
            _StatCard(icon: Icons.task, label: 'المهام', value: tasks ?? 0),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
