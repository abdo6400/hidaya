import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:hidaya/controllers/children_controller.dart';
import 'package:hidaya/services/attendance_service.dart';
import 'package:hidaya/services/results_service.dart';

class ParentScreen extends ConsumerWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    if (user == null) return const SizedBox.shrink();
    final childrenAsync = ref.watch(childrenControllerProvider(user.id));

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('لوحة ولي الأمر')),
          body: childrenAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (children) {
              if (children.isEmpty) return const Center(child: Text('لا يوجد أطفال مضافين'));
              return ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, i) {
                  final c = children[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ExpansionTile(
                      title: Text(c.name),
                      subtitle: Text(c.isApproved ? 'مقبول' : 'قيد المراجعة'),
                      children: [
                        _ChildAttendance(childId: c.id),
                        const Divider(height: 1),
                        _ChildResults(childId: c.id),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChildAttendance extends StatefulWidget {
  final String childId;
  const _ChildAttendance({required this.childId});

  @override
  State<_ChildAttendance> createState() => _ChildAttendanceState();
}

class _ChildAttendanceState extends State<_ChildAttendance> {
  final AttendanceService _attendanceService = AttendanceService();
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _attendanceService.getAttendanceOfStudent(widget.childId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('خطأ في الحضور: ${snap.error}'),
          );
        }
        final items = snap.data ?? const <Map<String, dynamic>>[];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('لا توجد سجلات حضور'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.take(7).map((e) {
            return ListTile(
              dense: true,
              leading: const Icon(Icons.event_available),
              title: Text(e['date'] as String),
              trailing: Text(e['status'] as String),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ChildResults extends StatefulWidget {
  final String childId;
  const _ChildResults({required this.childId});

  @override
  State<_ChildResults> createState() => _ChildResultsState();
}

class _ChildResultsState extends State<_ChildResults> {
  final ResultsService _resultsService = ResultsService();
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _resultsService.getResultsOfStudent(widget.childId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('خطأ في النتائج: ${snap.error}'),
          );
        }
        final items = snap.data ?? const <Map<String, dynamic>>[];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('لا توجد نتائج'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.take(7).map((e) {
            return ListTile(
              dense: true,
              leading: const Icon(Icons.task_alt),
              title: Text(e['taskTitle'] as String? ?? 'مهمة'),
              subtitle: Text(e['date'] as String),
              trailing: Text('${e['points']}'),
            );
          }).toList(),
        );
      },
    );
  }
}


