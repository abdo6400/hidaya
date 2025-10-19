import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../constants/index.dart';
import '../../bloc/index.dart';
import '../../models/index.dart';
import '../../services/firebase_service.dart';

class AddSheikhForm extends StatefulWidget {
  final Sheikh? sheikh; // For editing existing sheikh

  const AddSheikhForm({
    super.key,
    this.sheikh,
  });

  @override
  State<AddSheikhForm> createState() => _AddSheikhFormState();
}

class _AddSheikhFormState extends State<AddSheikhForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sheikh == null ? 'إضافة شيخ' : 'تعديل شيخ'),
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
                initialValue: widget.sheikh?.name ?? '',
                decoration: const InputDecoration(
                  labelText: 'اسم الشيخ',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                ]),
              ),
              const SizedBox(height: 16),

           

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSheikh,
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
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : Text(
                          widget.sheikh == null ? 'إضافة شيخ' : 'تحديث شيخ',
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

  Future<void> _saveSheikh() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final formData = _formKey.currentState!.value;
        
        final sheikh = Sheikh(
          id: widget.sheikh?.id ?? FirebaseService.generateId(),
          name: formData['name'],
        
          createdAt: widget.sheikh?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.sheikh == null) {
          context.read<SheikhsBloc>().add(AddSheikh(sheikh));
        } else {
          context.read<SheikhsBloc>().add(UpdateSheikh(sheikh));
        }

        // Wait a bit for the BLoC to process the event
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.sheikh == null ? 'تم إضافة الشيخ بنجاح' : 'تم تحديث الشيخ بنجاح',
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
