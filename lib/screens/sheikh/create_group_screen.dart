import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/schedule_groups_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/schedule_group_model.dart';
import '../../models/schedule_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<WeekDay> _selectedDays = [];
  final List<TimeSlot> _timeSlots = [];

  bool _isLoading = false;
  String? _selectedCategoryId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider);
    final categories = ref.watch(categoryControllerProvider);

    if (user == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('إنشاء مجموعة جديدة')),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Group Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المجموعة',
                    hintText: 'مثال: مجموعة القرآن - المستوى الأول',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال اسم المجموعة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Group Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'وصف المجموعة (اختياري)',
                    hintText: 'وصف مختصر عن المجموعة',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Days Selection
                const Text(
                  'أيام الدراسة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildDaysSelection(),
                const SizedBox(height: 24),

                // Time Slots
                const Text(
                  'المواعيد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildTimeSlotsSection(),
                const SizedBox(height: 24),

                // Category Selection
                const Text(
                  'التصنيف',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildCategorySelection(categories),
                const SizedBox(height: 32),

                // Create Button
                PrimaryButton(
                  text: 'إنشاء المجموعة',
                  onPressed: _isLoading ? null : () => _createGroup(user.id),
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysSelection() {
    final days = [
      {'day': WeekDay.sunday, 'name': 'الأحد'},
      {'day': WeekDay.monday, 'name': 'الاثنين'},
      {'day': WeekDay.tuesday, 'name': 'الثلاثاء'},
      {'day': WeekDay.wednesday, 'name': 'الأربعاء'},
      {'day': WeekDay.thursday, 'name': 'الخميس'},
      {'day': WeekDay.friday, 'name': 'الجمعة'},
      {'day': WeekDay.saturday, 'name': 'السبت'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((dayData) {
        final day = dayData['day'] as WeekDay;
        final name = dayData['name'] as String;
        final isSelected = _selectedDays.contains(day);

        return FilterChip(
          label: Text(name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(day);
              } else {
                _selectedDays.remove(day);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotsSection() {
    return Column(
      children: [
        if (_timeSlots.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'لا توجد مواعيد محددة',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ..._timeSlots.asMap().entries.map((entry) {
            final index = entry.key;
            final slot = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('${slot.startTime} - ${slot.endTime}'),
                subtitle: Text('التصنيف: ${slot.categoryId}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _timeSlots.removeAt(index);
                    });
                  },
                ),
              ),
            );
          }).toList(),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _addTimeSlot,
          icon: const Icon(Icons.add),
          label: const Text('إضافة موعد'),
        ),
      ],
    );
  }

  Widget _buildCategorySelection(AsyncValue categories) {
    return categories.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) => Text('خطأ: $error'),
      data: (categoriesList) {
        return DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: 'اختر التصنيف',
            border: OutlineInputBorder(),
          ),
          items: categoriesList.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'يرجى اختيار التصنيف';
            }
            return null;
          },
        );
      },
    );
  }

  void _addTimeSlot() {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التصنيف أولاً')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _TimeSlotDialog(
        onTimeSlotAdded: (startTime, endTime) {
          setState(() {
            _timeSlots.add(
              TimeSlot(
                startTime: startTime,
                endTime: endTime,
                categoryId: _selectedCategoryId!,
              ),
            );
          });
        },
      ),
    );
  }

  Future<void> _createGroup(String sheikhId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار يوم واحد على الأقل')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check for schedule conflicts
      final hasConflict = await ref
          .read(scheduleGroupsControllerProvider(sheikhId).notifier)
          .hasScheduleConflict(_selectedDays, _timeSlots);

      if (hasConflict) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('هناك تعارض في المواعيد مع مجموعة أخرى'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Create day schedules
      final daySchedules = _selectedDays.map((day) {
        return DaySchedule(day: day, timeSlots: _timeSlots);
      }).toList();

      final group = ScheduleGroupModel(
        id: '',
        sheikhId: sheikhId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        days: daySchedules,
        createdAt: DateTime.now(),
      );

      await ref
          .read(scheduleGroupsControllerProvider(sheikhId).notifier)
          .addScheduleGroup(group);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء المجموعة بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _TimeSlotDialog extends StatefulWidget {
  final Function(String startTime, String endTime) onTimeSlotAdded;

  const _TimeSlotDialog({required this.onTimeSlotAdded});

  @override
  State<_TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<_TimeSlotDialog> {
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة موعد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('وقت البداية'),
            subtitle: Text(_startTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (time != null) {
                setState(() {
                  _startTime = time;
                });
              }
            },
          ),
          ListTile(
            title: const Text('وقت النهاية'),
            subtitle: Text(_endTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (time != null) {
                setState(() {
                  _endTime = time;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final startTime =
                '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
            final endTime =
                '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

            widget.onTimeSlotAdded(startTime, endTime);
            Navigator.pop(context);
          },
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
