import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/schedule_model.dart';
import '../../models/category_model.dart';
import '../../controllers/schedules_controller.dart';
import '../../controllers/category_controller.dart';
import 'manage_schedule_screen.dart';

class SchedulePreviewScreen extends ConsumerStatefulWidget {
  final String sheikhId;

  const SchedulePreviewScreen({super.key, required this.sheikhId});

  @override
  ConsumerState<SchedulePreviewScreen> createState() =>
      _SchedulePreviewScreenState();
}

class _SchedulePreviewScreenState extends ConsumerState<SchedulePreviewScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial load delayed to avoid widget lifecycle issues
    Future(() => _refreshSchedules());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshSchedules();
    }
  }

  Future<void> _refreshSchedules() async {
    await ref
        .read(schedulesControllerProvider(widget.sheikhId).notifier)
        .loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsyncValue = ref.watch(
      schedulesControllerProvider(widget.sheikhId),
    );
    final categoryAsyncValue = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate and wait for result
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ManageScheduleScreen(sheikhId: widget.sheikhId),
                ),
              );
              // Refresh data when returning
              if (mounted) {
                _refreshSchedules();
              }
            },
          ),
        ],
      ),
      body: scheduleAsyncValue.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(child: Text('No schedule found'));
          }

          return categoryAsyncValue.when(
            data: (categories) {
              final schedule = schedules.first;
              return RefreshIndicator(
                onRefresh: _refreshSchedules,
                child: ListView.builder(
                  itemCount: WeekDay.values.length,
                  itemBuilder: (context, index) {
                    final day = WeekDay.values[index];
                    final daySchedule = schedule.days.firstWhere(
                      (d) => d.day == day,
                      orElse: () => DaySchedule(day: day, timeSlots: []),
                    );

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Text(
                          day.name[0].toUpperCase() + day.name.substring(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: daySchedule.timeSlots.map((slot) {
                          final category = categories.firstWhere(
                            (c) => c.id == slot.categoryId,
                            orElse: () => CategoryModel(
                              id: '',
                              name: 'Unknown Category',
                              description: '',
                            ),
                          );

                          return ListTile(
                            leading: const Icon(Icons.schedule),
                            title: Text('${slot.startTime} - ${slot.endTime}'),
                            subtitle: Text(category.name),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Error loading categories: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading schedule: $error')),
      ),
    );
  }
}
