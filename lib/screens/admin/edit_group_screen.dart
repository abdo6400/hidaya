import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/schedule_groups_controller.dart';
import 'package:hidaya/controllers/category_controller.dart';
import 'package:hidaya/controllers/sheikhs_controller.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/schedule_model.dart';
import 'package:hidaya/models/category_model.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/primary_button.dart';

class EditGroupScreen extends ConsumerStatefulWidget {
  final ScheduleGroupModel group;

  const EditGroupScreen({super.key, required this.group});

  @override
  ConsumerState<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends ConsumerState<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedSheikhId;
  List<DaySchedule> _days = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.name;
    _descriptionController.text = widget.group.description;
    _selectedCategoryId = widget.group.categoryId;
    _selectedSheikhId = widget.group.sheikhId;
    _days = List.from(widget.group.days);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryControllerProvider);
            final sheikhsAsync = ref.watch(sheikhsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تعديل المجموعة'), centerTitle: true),
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

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'وصف المجموعة',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Category Selection
            categoriesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (error, stack) =>
                  app_error.AppErrorWidget(message: error.toString()),
              data: (categories) => DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
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
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار التصنيف';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Sheikh Selection
            sheikhsAsync.when(
              loading: () => const LoadingIndicator(),
              error: (error, stack) =>
                  app_error.AppErrorWidget(message: error.toString()),
              data: (sheikhs) => DropdownButtonFormField<String>(
                initialValue: _selectedSheikhId,
                decoration: const InputDecoration(
                  labelText: 'الشيخ',
                  border: OutlineInputBorder(),
                ),
                items: sheikhs.map((sheikh) {
                  return DropdownMenuItem(
                    value: sheikh.id,
                    child: Text(sheikh.username),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSheikhId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار الشيخ';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),

            // Current Schedule
            const Text(
              'المواعيد الحالية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_days.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('لا توجد مواعيد محددة'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final day = _days[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(day.day.displayName),
                      subtitle: Text(
                        day.timeSlots
                            .map(
                              (slot) => '${slot.startTime} - ${slot.endTime}',
                            )
                            .join(', '),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _days.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),

            // Add New Time Slot Button
            ElevatedButton.icon(
              onPressed: _addTimeSlot,
              icon: const Icon(Icons.add),
              label: const Text('إضافة موعد جديد'),
            ),

            const SizedBox(height: 32),

            // Save Button
            PrimaryButton(
              onPressed: _isLoading ? null : _saveGroup,
              text: 'حفظ التغييرات',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  void _addTimeSlot() {
    showDialog(
      context: context,
      builder: (context) => _TimeSlotDialog(
        selectedCategoryId: _selectedCategoryId,
        onTimeSlotAdded: (daySchedule) {
          setState(() {
            // Remove existing day if it exists
            _days.removeWhere((d) => d.day == daySchedule.day);
            // Add new day schedule
            _days.add(daySchedule);
          });
        },
      ),
    );
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedSheikhId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedGroup = widget.group.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        sheikhId: _selectedSheikhId!,
        days: _days,
        updatedAt: DateTime.now(),
      );

      await ref
          .read(scheduleGroupsControllerProvider.notifier)
          .updateScheduleGroup(updatedGroup);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المجموعة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث المجموعة: $error'),
            backgroundColor: Colors.red,
          ),
        );
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

class _TimeSlotDialog extends ConsumerStatefulWidget {
  final String? selectedCategoryId;
  final Function(DaySchedule) onTimeSlotAdded;

  const _TimeSlotDialog({
    required this.selectedCategoryId,
    required this.onTimeSlotAdded,
  });

  @override
  ConsumerState<_TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends ConsumerState<_TimeSlotDialog> {
  WeekDay _selectedDay = WeekDay.monday;
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryControllerProvider);

    return AlertDialog(
      title: const Text('إضافة موعد جديد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day Selection
          DropdownButtonFormField<WeekDay>(
            initialValue: _selectedDay,
            decoration: const InputDecoration(
              labelText: 'اليوم',
              border: OutlineInputBorder(),
            ),
            items: WeekDay.values.map((day) {
              return DropdownMenuItem(value: day, child: Text(day.displayName));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedDay = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Category Selection
          categoriesAsync.when(
            loading: () => const LoadingIndicator(),
            error: (error, stack) =>
                app_error.AppErrorWidget(message: error.toString()),
            data: (categories) => DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'التصنيف',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
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
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار التصنيف';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Time Selection
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startTimeController,
                  decoration: const InputDecoration(
                    labelText: 'وقت البداية',
                    border: OutlineInputBorder(),
                    hintText: '09:00',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'مطلوب';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _endTimeController,
                  decoration: const InputDecoration(
                    labelText: 'وقت النهاية',
                    border: OutlineInputBorder(),
                    hintText: '10:00',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'مطلوب';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(onPressed: _addTimeSlot, child: const Text('إضافة')),
      ],
    );
  }

  void _addTimeSlot() {
    if (_startTimeController.text.trim().isEmpty ||
        _endTimeController.text.trim().isEmpty ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final timeSlot = TimeSlot(
      startTime: _startTimeController.text.trim(),
      endTime: _endTimeController.text.trim(),
      categoryId: _selectedCategoryId!,
    );

    final daySchedule = DaySchedule(day: _selectedDay, timeSlots: [timeSlot]);

    widget.onTimeSlotAdded(daySchedule);
    Navigator.of(context).pop();
  }
}
