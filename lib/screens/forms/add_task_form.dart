import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../constants/index.dart';
import '../../bloc/index.dart';
import '../../models/index.dart';
import '../../services/firebase_service.dart';

class AddTaskForm extends StatefulWidget {
  final Task? task; // For editing existing task

  const AddTaskForm({
    super.key,
    this.task,
  });

  static Future<void> showAsDialog(
    BuildContext context, {
    Task? task,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AddTaskForm(task: task),
          ),
        ),
      ),
    );
  }

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  TaskType _selectedTaskType = TaskType.graded;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _selectedTaskType = widget.task!.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'إضافة مهمة جديدة' : 'تعديل المهمة'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Name
              FormBuilderTextField(
                name: 'name',
                initialValue: widget.task?.name ?? '',
                decoration: const InputDecoration(
                  labelText: AppStrings.taskName,
                  hintText: 'أدخل اسم المهمة',
                  prefixIcon: Icon(Icons.assignment),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: AppStrings.requiredField,
                  ),
                  FormBuilderValidators.minLength(
                    2,
                    errorText: AppStrings.nameTooShort,
                  ),
                  FormBuilderValidators.maxLength(
                    100,
                    errorText: AppStrings.nameTooLong,
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Task Type
              FormBuilderDropdown<TaskType>(
                name: 'type',
                initialValue: widget.task?.type ?? TaskType.graded,
                decoration: const InputDecoration(
                  labelText: AppStrings.taskType,
                  prefixIcon: Icon(Icons.category),
                ),
                items: TaskType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type == TaskType.graded 
                          ? AppStrings.gradedTask 
                          : AppStrings.attendanceTask,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTaskType = value ?? TaskType.graded;
                  });
                },
                validator: FormBuilderValidators.required(
                  errorText: AppStrings.requiredField,
                ),
              ),
              const SizedBox(height: 16),

              // Max Score (only for graded tasks)
              if (_selectedTaskType == TaskType.graded)
                FormBuilderTextField(
                  name: 'maxScore',
                  initialValue: widget.task?.maxScore?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: AppStrings.maxScore,
                    hintText: 'أدخل الدرجة القصوى',
                    prefixIcon: Icon(Icons.star),
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: AppStrings.requiredField,
                    ),
                    FormBuilderValidators.numeric(
                      errorText: AppStrings.invalidScore,
                    ),
                    FormBuilderValidators.min(
                      0.1,
                      errorText: 'الدرجة يجب أن تكون أكبر من 0',
                    ),
                    FormBuilderValidators.max(
                      100,
                      errorText: 'الدرجة يجب أن تكون أقل من أو تساوي 100',
                    ),
                  ]),
                ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      child: const Text(AppStrings.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      
      final task = Task(
        id: widget.task?.id ?? FirebaseService.generateId(),
        name: formData['name'],
        type: formData['type'],
        maxScore: formData['type'] == TaskType.graded 
            ? double.tryParse(formData['maxScore'] ?? '0') 
            : null,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        if (widget.task == null) {
          context.read<TasksBloc>().add(AddTask(task));
        } else {
          context.read<TasksBloc>().add(UpdateTask(task));
        }
        
        // Wait a bit for the BLoC to process the event
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.task == null 
                    ? AppStrings.taskAddedSuccessfully 
                    : AppStrings.taskUpdatedSuccessfully,
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المهمة "${widget.task?.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TasksBloc>().add(DeleteTask(widget.task!.id));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
