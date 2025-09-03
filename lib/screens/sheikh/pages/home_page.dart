import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/providers/firebase_providers.dart';
import 'package:hidaya/utils/app_theme.dart';

class SheikhHomePage extends ConsumerWidget {
  final String sheikhId;
  const SheikhHomePage({super.key, required this.sheikhId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildWelcomeHeader(context)),
        SliverToBoxAdapter(child: _buildQuickStats(context, ref)),
        SliverToBoxAdapter(child: _buildTodaySchedule(context, ref)),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.person, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('مرحباً بك في هداية', style: AppTheme.islamicTitleStyle.copyWith(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 4),
            Text('أدير فصولك التعليمية بكل سهولة', style: AppTheme.arabicTextStyle.copyWith(color: Colors.white.withOpacity(0.9), fontSize: 16)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    final asyncStats = ref.watch(sheikhHomeStatsProvider(sheikhId));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ملخص سريع', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        asyncStats.when(
          loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator())),
          error: (e, st) => const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('تعذر تحميل الإحصائيات')),
          data: (stats) => Column(children: [
            Row(children: [
              Expanded(child: _statCard(context, 'إجمالي الطلاب', '${stats['totalStudents'] ?? 0}', Icons.school, AppTheme.primaryColor)),
              const SizedBox(width: 16),
              Expanded(child: _statCard(context, 'عدد المجموعات', '${stats['groupsCount'] ?? 0}', Icons.groups, AppTheme.successColor)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _statCard(context, 'تكليفات نشطة', '${stats['activeAssignments'] ?? 0}', Icons.task_alt, AppTheme.infoColor)),
              const SizedBox(width: 16),
              Expanded(child: _statCard(context, 'نتائج مكتملة', '${stats['completedResults'] ?? 0}', Icons.check_circle, AppTheme.warningColor)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
      ]),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
        const SizedBox(height: 12),
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildTodaySchedule(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(sheikhTodayGroupsProvider(sheikhId));
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('جدول اليوم', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        asyncGroups.when(
          loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator())),
          error: (e, st) => const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('تعذر تحميل الجدول')),
          data: (groups) {
            if (groups.isEmpty) {
              return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('لا توجد حصص اليوم', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])));
            }
            return Column(children: groups.map((g) {
              final today = g.days.isNotEmpty ? g.days.first : g.days.first;
              final time = today.timeSlots.isNotEmpty ? '${today.timeSlots.first.startTime} - ${today.timeSlots.first.endTime}' : '';
              return _scheduleCard(context, time.isEmpty ? '—' : time, 'المجموعة', g.name, Icons.groups, AppTheme.primaryColor);
            }).toList());
          },
        ),
      ]),
    );
  }

  Widget _scheduleCard(BuildContext context, String time, String subject, String group, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(subject, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(group, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
            ])),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ]),
        ),
      ),
    );
  }
}


