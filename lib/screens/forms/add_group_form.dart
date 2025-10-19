import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../constants/index.dart';
import '../../bloc/index.dart';
import '../../models/index.dart';
import '../../services/firebase_service.dart';

class AddGroupForm extends StatefulWidget {
  final Group? group; // For editing existing group

  const AddGroupForm({super.key, this.group});

  @override
  State<AddGroupForm> createState() => _AddGroupFormState();
}

class _AddGroupFormState extends State<AddGroupForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  List<Sheikh> _sheikhs = [];

  @override
  void initState() {
    super.initState();
    _loadSheikhs();
  }

  Future<void> _loadSheikhs() async {
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
  }

  String? _getInitialSheikhId() {
    // If editing and the group's sheikh exists in the list, use it
    if (widget.group?.sheikhId != null) {
      final sheikhExists = _sheikhs.any((s) => s.id == widget.group!.sheikhId);
      if (sheikhExists) {
        return widget.group!.sheikhId;
      }
    }
    // Otherwise, use first available sheikh or null
    return _sheikhs.isNotEmpty ? _sheikhs.first.id : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group == null ? 'إضافة مجموعة' : 'تعديل مجموعة'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Name Field
              FormBuilderTextField(
                name: 'name',
                initialValue: widget.group?.name ?? '',
                decoration: const InputDecoration(
                  labelText: 'اسم المجموعة',
                  prefixIcon: Icon(Icons.group),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                ]),
              ),
              const SizedBox(height: 16),

              // Sheikh Selection
              FormBuilderDropdown<String>(
                name: 'sheikhId',
                initialValue: _getInitialSheikhId(),
                decoration: const InputDecoration(
                  labelText: 'الشيخ المسؤول',
                  prefixIcon: Icon(Icons.person),
                ),
                items: _sheikhs.map((sheikh) {
                  return DropdownMenuItem(
                    value: sheikh.id,
                    child: Text(
                      sheikh.name,
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  );
                }).toList(),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.group == null
                              ? 'إضافة مجموعة'
                              : 'تحديث مجموعة',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGroup() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final formData = _formKey.currentState!.value;

        final group = Group(
          id: widget.group?.id ?? FirebaseService.generateId(),
          name: formData['name'],

          sheikhId: formData['sheikhId'],

          createdAt: widget.group?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.group == null) {
          context.read<GroupsBloc>().add(AddGroup(group));
        } else {
          context.read<GroupsBloc>().add(UpdateGroup(group));
        }

        // Wait a bit for the BLoC to process the event
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.group == null
                    ? 'تم إضافة المجموعة بنجاح'
                    : 'تم تحديث المجموعة بنجاح',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'حدث خطأ: ${e.toString()}',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.error,
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
}
