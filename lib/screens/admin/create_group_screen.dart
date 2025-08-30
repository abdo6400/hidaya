import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/schedule_groups_controller.dart';
import 'package:hidaya/controllers/sheiks_controller.dart';
import 'package:hidaya/controllers/category_controller.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/schedule_model.dart';
import 'package:hidaya/models/category_model.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/primary_button.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final Set<WeekDay> _selectedDays = {};
  final List<TimeSlot> _timeSlots = [];
  String? _selectedSheikhId;
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار يوم واحد على الأقل')),
      );
      return;
    }
    if (_selectedSheikhId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار شيخ')));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار تصنيف')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hasConflict = await ref
          .read(scheduleGroupsControllerProvider('admin').notifier)
          .hasScheduleConflict(_selectedDays.toList(), _timeSlots);

      if (hasConflict) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هناك تعارض في المواعيد مع مجموعة أخرى'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final daySchedules = _selectedDays
          .map((day) => DaySchedule(day: day, timeSlots: _timeSlots))
          .toList();

      final group = ScheduleGroupModel(
        id: '',
        sheikhId: _selectedSheikhId!,
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        days: daySchedules,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await ref
          .read(scheduleGroupsControllerProvider('admin').notifier)
          .addScheduleGroup(group);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء المجموعة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء المجموعة: $error'),
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

  void _addTimeSlot() {
    showDialog(
      context: context,
      builder: (context) => _TimeSlotDialog(
        selectedCategoryId: _selectedCategoryId,
        onTimeSlotAdded: (timeSlot) {
          setState(() {
            _timeSlots.add(timeSlot);
          });
        },
      ),
    );
  }

  void _removeTimeSlot(int index) {
    setState(() {
      _timeSlots.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء مجموعة جديدة'),
        centerTitle: true,
      ),
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
                  return 'الرجاء إدخال اسم المجموعة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'وصف المجموعة (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Sheikh Selection
            Consumer(
              builder: (context, ref, child) {
                final sheikhsAsync = ref.watch(sheiksControllerProvider);

                return sheikhsAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (error, stack) =>
                      app_error.AppErrorWidget(message: error.toString()),
                  data: (sheikhs) {
                    return DropdownButtonFormField<String>(
                      value: _selectedSheikhId,
                      decoration: const InputDecoration(
                        labelText: 'اختر الشيخ',
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
                        if (value == null) {
                          return 'الرجاء اختيار شيخ';
                        }
                        return null;
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Category Selection
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(categoryControllerProvider);

                return categoriesAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (error, stack) =>
                      app_error.AppErrorWidget(message: error.toString()),
                  data: (categories) {
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'اختر التصنيف',
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
                        if (value == null) {
                          return 'الرجاء اختيار تصنيف';
                        }
                        return null;
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Days Selection
            const Text(
              'أيام الدراسة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: WeekDay.values.map((day) {
                final isSelected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(_getDayName(day)),
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
            ),
            const SizedBox(height: 16),

            // Time Slots
            Row(
              children: [
                const Text(
                  'المواعيد',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _addTimeSlot,
                  icon: const Icon(Icons.add),
                  tooltip: 'إضافة موعد',
                ),
              ],
            ),
            if (_timeSlots.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'لا توجد مواعيد محددة',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _timeSlots.length,
                itemBuilder: (context, index) {
                  final timeSlot = _timeSlots[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        '${timeSlot.startTime} - ${timeSlot.endTime}',
                      ),
                      subtitle: Consumer(
                        builder: (context, ref, child) {
                          final categoriesAsync = ref.watch(
                            categoryControllerProvider,
                          );
                          return categoriesAsync.when(
                            loading: () => const Text('جاري التحميل...'),
                            error: (error, stack) =>
                                const Text('خطأ في التحميل'),
                            data: (categories) {
                              final category = categories.firstWhere(
                                (cat) => cat.id == timeSlot.categoryId,
                                orElse: () => CategoryModel(
                                  id: '',
                                  name: 'غير محدد',
                                  description: '',
                                ),
                              );
                              return Text('التصنيف: ${category.name}');
                            },
                          );
                        },
                      ),
                      trailing: IconButton(
                        onPressed: () => _removeTimeSlot(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // Create Button
            PrimaryButton(
              text: 'إنشاء المجموعة',
              onPressed: _createGroup,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(WeekDay day) {
    switch (day) {
      case WeekDay.sunday:
        return 'الأحد';
      case WeekDay.monday:
        return 'الاثنين';
      case WeekDay.tuesday:
        return 'الثلاثاء';
      case WeekDay.wednesday:
        return 'الأربعاء';
      case WeekDay.thursday:
        return 'الخميس';
      case WeekDay.friday:
        return 'الجمعة';
      case WeekDay.saturday:
        return 'السبت';
    }
  }
}

class _TimeSlotDialog extends StatefulWidget {
  final Function(TimeSlot) onTimeSlotAdded;
  final String? selectedCategoryId;

  const _TimeSlotDialog({
    required this.onTimeSlotAdded,
    this.selectedCategoryId,
  });

  @override
  State<_TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<_TimeSlotDialog> {
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة موعد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('وقت البداية'),
            subtitle: Text(_startTime.format(context)),
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
            leading: const Icon(Icons.access_time),
            title: const Text('وقت النهاية'),
            subtitle: Text(_endTime.format(context)),
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
          const SizedBox(height: 16),
          // Category Selection
          Consumer(
            builder: (context, ref, child) {
              final categoriesAsync = ref.watch(categoryControllerProvider);

              return categoriesAsync.when(
                loading: () => const LoadingIndicator(),
                error: (error, stack) =>
                    app_error.AppErrorWidget(message: error.toString()),
                data: (categories) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'اختر التصنيف',
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
                      if (value == null) {
                        return 'الرجاء اختيار تصنيف';
                      }
                      return null;
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final timeSlot = TimeSlot(
              startTime: _startTime.format(context),
              endTime: _endTime.format(context),
              categoryId: _selectedCategoryId ?? '',
            );
            widget.onTimeSlotAdded(timeSlot);
            Navigator.of(context).pop();
          },
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
