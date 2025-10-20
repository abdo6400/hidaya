import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../constants/index.dart';
import '../../bloc/index.dart';
import '../../models/index.dart';
import '../../services/index.dart';

class AddStudentForm extends StatefulWidget {
  final Student? student; // For editing existing student
  final String? groupId; // Pre-select group if coming from group screen

  const AddStudentForm({super.key, this.student, this.groupId});

  static Future<void> showAsDialog(
    BuildContext context, {
    Student? student,
    String? groupId,
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
            child: AddStudentForm(student: student, groupId: groupId),
          ),
        ),
      ),
    );
  }

  @override
  State<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  List<Sheikh> _sheikhs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      context.read<SheikhsBloc>().add(LoadSheikhs());
      context.read<SheikhsBloc>().stream.listen((state) {
        if (mounted) {
          setState(() {
            if (state is SheikhsLoaded) {
              _sheikhs = state.sheikhs;
            }
          });
        }
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _getInitialSheikhId() {
    // If editing and the student's sheikh exists in the list, use it
    if (widget.student?.sheikhId != null) {
      final sheikhExists = _sheikhs.any(
        (s) => s.id == widget.student!.sheikhId,
      );
      if (sheikhExists) {
        return widget.student!.sheikhId;
      }
    }
    // Otherwise, use first available sheikh or null
    return _sheikhs.isNotEmpty ? _sheikhs.first.id : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.student == null ? 'إضافة طالب جديد' : 'تعديل الطالب',
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          if (widget.student != null)
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
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Name
                    FormBuilderTextField(
                      name: 'name',
                      initialValue: widget.student?.name ?? '',
                      decoration: const InputDecoration(
                        labelText: AppStrings.studentName,
                        hintText: 'أدخل اسم الطالب',
                        prefixIcon: Icon(Icons.person),
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
                          50,
                          errorText: AppStrings.nameTooLong,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Sheikh Selection
                    FormBuilderDropdown<String>(
                      name: 'sheikhId',
                      initialValue: _getInitialSheikhId(),
                      decoration: const InputDecoration(
                        labelText: AppStrings.assignedSheikh,
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _sheikhs.map((sheikh) {
                        return DropdownMenuItem(
                          value: sheikh.id,
                          child: Text(sheikh.name),
                        );
                      }).toList(),
                      validator: FormBuilderValidators.required(
                        errorText: AppStrings.requiredField,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                            onPressed: _saveStudent,
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

  Future<void> _saveStudent() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final sheikh = _sheikhs.firstWhere((s) => s.id == formData['sheikhId']);
      final student = Student(
        id: widget.student?.id ?? FirebaseService.generateId(),
        name: formData['name'],
        sheikhId: formData['sheikhId'],
        sheikhName: sheikh.name,
        createdAt: widget.student?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        if (widget.student == null) {
          context.read<StudentsBloc>().add(AddStudent(student));
        } else {
          context.read<StudentsBloc>().add(UpdateStudent(student));
        }

        // Wait a bit for the BLoC to process the event
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.student == null
                    ? AppStrings.studentAddedSuccessfully
                    : AppStrings.studentUpdatedSuccessfully,
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
        content: Text('هل أنت متأكد من حذف الطالب "${widget.student?.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<StudentsBloc>().add(
                DeleteStudent(widget.student!.id),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
