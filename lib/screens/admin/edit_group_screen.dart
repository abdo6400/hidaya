import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/controllers/schedule_groups_controller.dart';
import 'package:hidaya/controllers/sheikhs_controller.dart';
import 'package:hidaya/controllers/category_controller.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/schedule_model.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/models/category_model.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

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

  String? _selectedSheikhId;
  String? _selectedCategoryId;
  List<WeekDay> _selectedDays = [];
  List<TimeSlot> _timeSlots = [];

  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.group.name;
    _descriptionController.text = widget.group.description;
    _selectedSheikhId = widget.group.sheikhId;
    _selectedCategoryId = widget.group.categoryId;
    _selectedDays = widget.group.weekDays;
    _timeSlots = widget.group.days.isNotEmpty
        ? List.from(widget.group.days.first.timeSlots)
        : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheikhsAsync = ref.watch(sheikhsControllerProvider);
    final categoriesAsync = ref.watch(categoryControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تعديل المجموعة: ${widget.group.name}'),
          // backgroundColor: AppTheme.primaryColor,
          // foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _isSubmitting ? null : _saveGroup,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              tooltip: 'حفظ',
            ),
          ],
        ),
        body: _isLoading
            ? const LoadingIndicator()
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Group Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المجموعة',
                        hintText: 'أدخل اسم المجموعة',
                        prefixIcon: const Icon(Icons.group),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'اسم المجموعة مطلوب';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'وصف المجموعة',
                        hintText: 'أدخل وصف المجموعة',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // Sheikh Selection
                    sheikhsAsync.when(
                      data: (sheikhs) => DropdownButtonFormField<String>(
                        value: _selectedSheikhId,
                        decoration: InputDecoration(
                          labelText: 'الشيخ',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: sheikhs.map((sheikh) {
                          return DropdownMenuItem(
                            value: sheikh.id,
                            child: Text(sheikh.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSheikhId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'اختيار الشيخ مطلوب';
                          }
                          return null;
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text('خطأ: $error'),
                    ),

                    const SizedBox(height: 16),

                    // Category Selection
                    categoriesAsync.when(
                      data: (categories) => DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'الفئة',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            return 'اختيار الفئة مطلوب';
                          }
                          return null;
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text('خطأ: $error'),
                    ),

                    const SizedBox(height: 24),

                    // Days Selection
                    Text(
                      'أيام الدراسة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryColor,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Time Slots
                    Row(
                      children: [
                        Text(
                          'أوقات الدراسة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _addTimeSlot,
                          icon: const Icon(Icons.add),
                          tooltip: 'إضافة وقت',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_timeSlots.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Text(
                            'لا توجد أوقات محددة',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
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
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: timeSlot.startTime,
                                    decoration: InputDecoration(
                                      labelText: 'وقت البداية',
                                      hintText: '09:00',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      _timeSlots[index] = TimeSlot(
                                        startTime: value,
                                        endTime: timeSlot.endTime,
                                        categoryId: timeSlot.categoryId,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: timeSlot.endTime,
                                    decoration: InputDecoration(
                                      labelText: 'وقت النهاية',
                                      hintText: '10:00',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      _timeSlots[index] = TimeSlot(
                                        startTime: timeSlot.startTime,
                                        endTime: value,
                                        categoryId: timeSlot.categoryId,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _removeTimeSlot(index),
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: AppTheme.errorColor,
                                  tooltip: 'إزالة الوقت',
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _saveGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'حفظ التغييرات',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _getDayName(WeekDay day) {
    switch (day) {
      case WeekDay.saturday:
        return 'السبت';
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
    }
  }

  void _addTimeSlot() {
    setState(() {
      _timeSlots.add(
        TimeSlot(
          startTime: '',
          endTime: '',
          categoryId: _selectedCategoryId ?? '',
        ),
      );
    });
  }

  void _removeTimeSlot(int index) {
    setState(() {
      _timeSlots.removeAt(index);
    });
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار يوم واحد على الأقل'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_timeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة وقت واحد على الأقل'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Validate time slots
    for (final timeSlot in _timeSlots) {
      if (timeSlot.startTime.isEmpty || timeSlot.endTime.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى ملء جميع الأوقات'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      // Check for schedule conflicts
      final hasConflict = await ref
          .read(scheduleGroupsControllerProvider.notifier)
          .hasScheduleConflict(
            _selectedDays,
            _timeSlots,
            excludeGroupId: widget.group.id,
          );

      if (hasConflict) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('هناك تعارض في الجدول مع مجموعة أخرى'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }

      // Create updated group
      final daySchedules = _selectedDays
          .map((day) => DaySchedule(day: day, timeSlots: _timeSlots))
          .toList();

      final updatedGroup = widget.group.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        sheikhId: _selectedSheikhId!,
        categoryId: _selectedCategoryId!,
        days: daySchedules,
        updatedAt: DateTime.now(),
      );

      // Update the group
      await ref
          .read(scheduleGroupsControllerProvider.notifier)
          .updateScheduleGroup(updatedGroup);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المجموعة بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحديث المجموعة: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
