import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../constants/index.dart';
import '../../bloc/index.dart';
import '../../models/index.dart';
import '../../services/firebase_service.dart';

class AddResultForm extends StatefulWidget {
  final String? studentId; // Pre-select student if coming from student screen
  final String? taskId; // Pre-select task if coming from task screen
  final Result? result; // For editing existing result

  const AddResultForm({super.key, this.studentId, this.taskId, this.result});

  static Future<void> showAsDialog(
    BuildContext context, {
    String? studentId,
    String? taskId,
    Result? result,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        child: Container(
          width: MediaQuery.of(ctx).size.width * 0.9,
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AddResultForm(
              studentId: studentId,
              taskId: taskId,
              result: result,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<AddResultForm> createState() => _AddResultFormState();
}

class _AddResultFormState extends State<AddResultForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<Student> _students = [];
  List<Task> _tasks = [];
  Task? _selectedTask;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load students from BLoC
      context.read<StudentsBloc>().add(LoadStudents());
      context.read<StudentsBloc>().stream.listen((state) {
        if (mounted && state is StudentsLoaded) {
          setState(() {
            _students = state.students;
          });
        }
      });

      // Load tasks from BLoC
      context.read<TasksBloc>().add(LoadTasks());
      context.read<TasksBloc>().stream.listen((state) {
        if (mounted && state is TasksLoaded) {
          setState(() {
            _tasks = state.tasks;

            // Pre-select task if provided
            if (widget.taskId != null) {
              _selectedTask = _tasks.firstWhere(
                (task) => task.id == widget.taskId,
              );
            } else if (widget.result?.taskId != null) {
              _selectedTask = _tasks.firstWhere(
                (task) => task.id == widget.result!.taskId,
              );
            } else {
              _selectedTask = _tasks.isNotEmpty ? _tasks.first : null;
            }
          });
        }
      });
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _getInitialTaskId() {
    // If editing and the result's task exists in the list, use it
    if (widget.result?.taskId != null) {
      final taskExists = _tasks.any((t) => t.id == widget.result!.taskId);
      if (taskExists) {
        return widget.result!.taskId;
      }
    }
    // If pre-selected task exists in the list, use it
    if (widget.taskId != null) {
      final taskExists = _tasks.any((t) => t.id == widget.taskId);
      if (taskExists) {
        return widget.taskId;
      }
    }
    // Otherwise, use first available task or null
    return _tasks.isNotEmpty ? _tasks.first.id : null;
  }

  Widget _buildFormContent() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result Title - only for graded tasks
          if (_selectedTask?.type == TaskType.graded)
            Column(
              children: [
                FormBuilderTextField(
                  name: 'title',
                  initialValue: widget.result?.title ?? '',
                  decoration: const InputDecoration(
                    labelText: AppStrings.resultTitle,
                    hintText: 'أدخل عنوان النتيجة',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: AppStrings.requiredField,
                    ),
                    FormBuilderValidators.minLength(
                      2,
                      errorText: AppStrings.nameTooShort,
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
              ],
            )
          else
            // Hidden field for attendance tasks
            FormBuilderField<String>(
              name: 'title',
              initialValue: widget.result?.title ?? 'حضور',
              builder: (field) => const SizedBox.shrink(),
            ),

          // Student Selection
          if (widget.studentId == null && widget.result?.studentId == null)
            Column(
              children: [
                FormBuilderDropdown<String>(
                  name: 'studentId',
                  initialValue: _students.isNotEmpty
                      ? _students.first.id
                      : null,
                  decoration: const InputDecoration(
                    labelText: AppStrings.studentName,
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: _students.map((student) {
                    return DropdownMenuItem(
                      value: student.id,
                      child: Text(student.name),
                    );
                  }).toList(),
                  validator: FormBuilderValidators.required(
                    errorText: AppStrings.requiredField,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            )
          else
            // Add hidden field for pre-selected student
            FormBuilderField<String>(
              name: 'studentId',
              initialValue: widget.studentId ?? widget.result?.studentId,
              builder: (field) => const SizedBox.shrink(),
            ),
          // Show student name if pre-selected
          if (widget.studentId != null || widget.result?.studentId != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.studentName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _students
                        .firstWhere(
                          (s) =>
                              s.id ==
                              (widget.studentId ?? widget.result?.studentId),
                          orElse: () => Student(
                            id: '',
                            name: 'غير محدد',
                            sheikhId: '',
                            sheikhName: '',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        )
                        .name,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Task Selection
          FormBuilderDropdown<String>(
            name: 'taskId',
            initialValue: _getInitialTaskId(),
            decoration: const InputDecoration(
              labelText: AppStrings.taskName,
              prefixIcon: Icon(Icons.assignment),
            ),
            items: _tasks.map((task) {
              return DropdownMenuItem(value: task.id, child: Text(task.name));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTask = _tasks.firstWhere(
                  (task) => task.id == value,
                  orElse: () => _tasks.first,
                );
              });
            },
            validator: FormBuilderValidators.required(
              errorText: AppStrings.requiredField,
            ),
          ),
          const SizedBox(height: 16),

          // Result Input (Score or Attendance)
          if (_selectedTask?.type == TaskType.graded)
            FormBuilderTextField(
              name: 'score',
              initialValue: widget.result?.score?.toString() ?? '',
              decoration: InputDecoration(
                labelText: AppStrings.result,
                hintText:
                    'أدخل الدرجة (0 - ${_selectedTask?.maxScore?.toStringAsFixed(1) ?? '100'})',
                prefixIcon: const Icon(Icons.grade),
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
                  0,
                  errorText: 'الدرجة يجب أن تكون أكبر من أو تساوي 0',
                ),
                if (_selectedTask?.maxScore != null)
                  FormBuilderValidators.max(
                    _selectedTask!.maxScore!,
                    errorText:
                        'الدرجة يجب أن تكون أقل من أو تساوي ${_selectedTask!.maxScore!.toStringAsFixed(1)}',
                  ),
              ]),
            )
          else
            FormBuilderDropdown<bool>(
              name: 'attendance',
              initialValue: widget.result?.attendance ?? true,
              decoration: const InputDecoration(
                labelText: AppStrings.result,
                prefixIcon: Icon(Icons.check_circle),
              ),
              items: const [
                DropdownMenuItem(value: true, child: Text(AppStrings.yes)),
                DropdownMenuItem(value: false, child: Text(AppStrings.no)),
              ],
              validator: FormBuilderValidators.required(
                errorText: AppStrings.requiredField,
              ),
            ),
          const SizedBox(height: 16),

          // Date
          FormBuilderDateTimePicker(
            name: 'date',
            initialValue: widget.result?.date ?? DateTime.now(),
            decoration: const InputDecoration(
              labelText: AppStrings.date,
              prefixIcon: Icon(Icons.calendar_today),
            ),
            inputType: InputType.date,
            validator: FormBuilderValidators.required(
              errorText: AppStrings.requiredField,
            ),
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
                  onPressed: _saveResult,
                  child: const Text(AppStrings.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're in a dialog context by looking for a Dialog ancestor
    final isDialog = context.findAncestorWidgetOfExactType<Dialog>() != null;

    if (isDialog) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.result == null
                        ? 'إضافة نتيجة جديدة'
                        : 'تعديل النتيجة',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
                if (widget.result != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _showDeleteDialog,
                  ),
              ],
            ),
            const Divider(),
            // Form Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(child: _buildFormContent()),
            ),
          ],
        ),
      );
    } else {
      // Full screen mode
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.result == null ? 'إضافة نتيجة جديدة' : 'تعديل النتيجة',
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          actions: [
            if (widget.result != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _showDeleteDialog,
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildFormContent(),
              ),
      );
    }
  }

  Future<void> _saveResult() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      final result = Result(
        id: widget.result?.id ?? FirebaseService.generateId(),
        studentId: formData['studentId'],
        taskId: formData['taskId'],
        title: formData['title'],
        score: _selectedTask?.type == TaskType.graded
            ? double.tryParse(formData['score'] ?? '0')
            : null,
        attendance: _selectedTask?.type == TaskType.attendance
            ? formData['attendance']
            : null,
        date: formData['date'],
        createdAt: widget.result?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.result == null) {
        context.read<ResultsBloc>().add(AddResult(result));
      } else {
        context.read<ResultsBloc>().add(UpdateResult(result));
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.result == null
                  ? AppStrings.resultAddedSuccessfully
                  : AppStrings.resultUpdatedSuccessfully,
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف النتيجة "${widget.result?.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ResultsBloc>().add(DeleteResult(widget.result!.id));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.resultDeletedSuccessfully),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
