import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../controllers/sheiks_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/sheikh_card.dart';

class SheikhsScreen extends ConsumerStatefulWidget {
  const SheikhsScreen({super.key});

  @override
  ConsumerState<SheikhsScreen> createState() => _SheikhsScreenState();
}

class _SheikhsScreenState extends ConsumerState<SheikhsScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sheiksControllerProvider.notifier).loadSheikhs());
  }

  void _openSheikhForm(BuildContext context, WidgetRef ref, {AppUser? sheikh}) {
    final formKey = GlobalKey<FormBuilderState>();

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(sheikh == null ? "إضافة شيخ" : "تعديل بيانات الشيخ"),
            content: SizedBox(
              width: 400,
              child: FormBuilder(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: "username",
                      initialValue: sheikh?.username,
                      decoration: const InputDecoration(labelText: "اسم المستخدم"),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: "مطلوب"),
                        FormBuilderValidators.minLength(3, errorText: "أدخل 3 أحرف على الأقل"),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: "phone",
                      initialValue: sheikh?.phone,
                      decoration: const InputDecoration(labelText: "رقم الهاتف"),
                      validator: FormBuilderValidators.required(errorText: "مطلوب"),
                    ),
                    const SizedBox(height: 12),
                    if (sheikh == null)
                      FormBuilderTextField(
                        name: "password",
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "كلمة المرور"),
                        validator: FormBuilderValidators.required(errorText: "مطلوب"),
                      ),
                    const SizedBox(height: 12),
                    FormBuilderSwitch(
                      name: "active",
                      initialValue: sheikh?.status == "active" || sheikh == null,
                      title: const Text("الحالة مفعلة"),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.saveAndValidate() ?? false) {
                    final values = formKey.currentState!.value;

                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    if (sheikh == null) {
                      await ref
                          .read(sheiksControllerProvider.notifier)
                          .addSheikh(
                            username: values["username"],
                            phone: values["phone"],
                            password: values["password"],
                            status: values["active"] ? "active" : "blocked",
                          );
                    } else {
                      await ref.read(sheiksControllerProvider.notifier).updateSheikh(sheikh.id, {
                        "username": values["username"],
                        "phone": values["phone"],
                        "status": values["active"] ? "active" : "blocked",
                      });
                    }

                    if (mounted) {
                      Navigator.pop(context); // close loading
                      Navigator.pop(context); // close form
                    }
                  }
                },
                child: Text(sheikh == null ? "إضافة" : "تحديث"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheikhsAsync = ref.watch(sheiksControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _openSheikhForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: "ابحث عن محفظ...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: sheikhsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("حدث خطأ: $err"),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.read(sheiksControllerProvider.notifier).loadSheikhs(),
                        child: const Text("إعادة المحاولة"),
                      ),
                    ],
                  ),
                ),
                data: (sheikhs) {
                  final filteredSheikhs = sheikhs
                      .where(
                        (s) =>
                            s.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            (s.phone ?? "").toLowerCase().contains(_searchQuery.toLowerCase()),
                      )
                      .toList();
                  if (filteredSheikhs.isEmpty) {
                    return const Center(child: Text("لا يوجد محفظ"));
                  }
                  return ListView.separated(
                    itemCount: filteredSheikhs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 5),
                    itemBuilder: (context, index) {
                      final sheikh = filteredSheikhs[index];
                      return SheikhCard(
                        sheikh: sheikh,
                        onEdit: (id) => _openSheikhForm(context, ref, sheikh: sheikh),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
