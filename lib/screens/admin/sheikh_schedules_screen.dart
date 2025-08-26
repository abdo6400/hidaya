// screens/sheikh_schedules_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/schedules_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/schedule_model.dart';
import '../../models/category_model.dart';

class SheikhSchedulesScreen extends ConsumerWidget {
  final String sheikhId;
  final String sheikhName;

  const SheikhSchedulesScreen({super.key, required this.sheikhId, required this.sheikhName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesState = ref.watch(schedulesControllerProvider(sheikhId));
    final categoriesState = ref.watch(categoryControllerProvider);

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text("جدول المواعيد - $sheikhName")),
          body: categoriesState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("خطأ بتحميل التصنيفات: $e")),
            data: (categories) {
              return schedulesState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("خطأ بتحميل المواعيد: $e")),
                data: (schedules) {
                  if (schedules.isEmpty) {
                    return const Center(child: Text("لا يوجد مواعيد"));
                  }

                  // اختياري: ترتيب حسب اليوم ثم الوقت
                  schedules.sort((a, b) {
                    final di = _dayIndex(a.day).compareTo(_dayIndex(b.day));
                    if (di != 0) return di;
                    return _timeToMinutes(a.startTime).compareTo(_timeToMinutes(b.startTime));
                  });

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: schedules.length,
                    itemBuilder: (context, i) {
                      final s = schedules[i];
                      final catName = _categoryName(s.categoryId, categories);
                      return _ScheduleCard(
                        schedule: s,
                        categoryName: catName,
                        onEdit: () => _showAddOrEditSheet(context, ref, categories, sheikhId, s),
                        onDelete: () => ref
                            .read(schedulesControllerProvider(sheikhId).notifier)
                            .deleteSchedule(s.id),
                      );
                    },
                  );
                },
              );
            },
          ),
          floatingActionButton: categoriesState.maybeWhen(
            orElse: () => null,
            data: (categories) => FloatingActionButton(
              heroTag: null,
              child: const Icon(Icons.add),
              onPressed: () => _showAddOrEditSheet(context, ref, categories, sheikhId, null),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Bottom sheet (Add/Edit) ----------
  void _showAddOrEditSheet(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> categories,
    String sheikhId,
    ScheduleModel? initial,
  ) {
    final formKey = GlobalKey<FormState>();
    final notesController = TextEditingController(text: initial?.notes ?? '');

    String? selectedDay = initial?.day;
    String? selectedCategoryId = initial?.categoryId;

    TimeOfDay? startTime = _tryParseTimeOfDay(initial?.startTime);
    TimeOfDay? endTime = _tryParseTimeOfDay(initial?.endTime);

    final days = const ["السبت", "الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  initial == null ? "إضافة موعد أسبوعي" : "تعديل الموعد",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // اليوم
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: "اليوم"),
                  items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => selectedDay = v,
                  validator: (v) => v == null ? "اختر اليوم" : null,
                ),
                const SizedBox(height: 12),

                // التصنيف (من مزود التصنيفات)
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(labelText: "التصنيف"),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => selectedCategoryId = v,
                  validator: (v) => v == null ? "اختر التصنيف" : null,
                ),
                const SizedBox(height: 12),

                // وقت البداية
                _TimePickerTile(
                  label: "وقت البداية",
                  value: startTime,
                  onPick: (t) => startTime = t,
                ),

                // وقت النهاية
                _TimePickerTile(label: "وقت النهاية", value: endTime, onPick: (t) => endTime = t),

                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: "ملاحظات (اختياري)"),
                  maxLines: 2,
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(initial == null ? Icons.add : Icons.save),
                    label: Text(initial == null ? "إضافة الموعد" : "حفظ التعديلات"),
                    onPressed: () {
                      final valid = formKey.currentState!.validate();
                      if (!valid || startTime == null || endTime == null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text("أكمل اليوم والوقت والتصنيف")));
                        return;
                      }
                      final startM = startTime!.hour * 60 + startTime!.minute;
                      final endM = endTime!.hour * 60 + endTime!.minute;
                      if (endM <= startM) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("وقت النهاية يجب أن يكون بعد البداية")),
                        );
                        return;
                      }

                      final schedule = ScheduleModel(
                        id: initial?.id ?? '',
                        sheikhId: sheikhId,
                        day: selectedDay!,
                        startTime: _formatTime(startTime!),
                        endTime: _formatTime(endTime!),
                        categoryId: selectedCategoryId!, // ← من DropDown
                        notes: notesController.text.trim(),
                      );

                      final notifier = ref.read(schedulesControllerProvider(sheikhId).notifier);
                      if (initial == null) {
                        notifier.addSchedule(schedule);
                      } else {
                        notifier.updateSchedule(schedule.id, schedule.toMap());
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======= UI widgets & helpers =======

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اليوم + المدى الزمني
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  schedule.day,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "${schedule.startTime} - ${schedule.endTime}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // التصنيف
            Row(
              children: [
                const Icon(Icons.category, size: 18, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "التصنيف: $categoryName",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),

            if ((schedule.notes).trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text("ملاحظات: ${schedule.notes}", style: const TextStyle(color: Colors.black54)),
            ],

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.blue),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerTile extends StatefulWidget {
  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onPick;

  const _TimePickerTile({required this.label, required this.value, required this.onPick});

  @override
  State<_TimePickerTile> createState() => _TimePickerTileState();
}

class _TimePickerTileState extends State<_TimePickerTile> {
  TimeOfDay? _local;

  @override
  void initState() {
    super.initState();
    _local = widget.value;
  }

  @override
  void didUpdateWidget(covariant _TimePickerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _local = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(_local == null ? widget.label : "${widget.label}: ${_local!.format(context)}"),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _local ?? TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() => _local = picked);
          widget.onPick(picked);
        }
      },
    );
  }
}

// ======= helpers =======
int _dayIndex(String day) {
  const days = ["السبت", "الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة"];
  final idx = days.indexOf(day);
  return idx == -1 ? 100 : idx;
}

int _timeToMinutes(String hhmm) {
  // expects "HH:MM" or localized from TimeOfDay.format(); we’ll try a simple parse
  final parts = hhmm.split(':');
  if (parts.length < 2) return 0;
  final h = int.tryParse(parts[0].replaceAll(RegExp(r'\D'), '')) ?? 0;
  final m = int.tryParse(parts[1].replaceAll(RegExp(r'\D'), '')) ?? 0;
  return h * 60 + m;
}

String _categoryName(String? id, List<CategoryModel> categories) {
  if (id == null) return "غير محدد";
  final c = categories.firstWhere(
    (e) => e.id == id,
    orElse: () => CategoryModel(id: '', name: 'غير معروف', description: ''),
  );
  return c.name;
}

TimeOfDay? _tryParseTimeOfDay(String? s) {
  if (s == null || s.isEmpty) return null;
  try {
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.parse(parts[0].replaceAll(RegExp(r'\D'), ''));
    final m = int.parse(parts[1].replaceAll(RegExp(r'\D'), ''));
    return TimeOfDay(hour: h, minute: m);
  } catch (_) {
    return null;
  }
}

String _formatTime(TimeOfDay t) {
  // Store as "HH:MM" 24h; UI shows localized via format() if you prefer.
  final hh = t.hour.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  return "$hh:$mm";
}
