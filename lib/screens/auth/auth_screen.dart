import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../controllers/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isRegister = false;
  bool loading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final authController = ref.read(authControllerProvider.notifier);
    final surface = Theme.of(context).colorScheme.surface;
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w400);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        'assets/icons/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "مرحباً بك في هداية",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "سجّل دخولك أو أنشئ حسابًا جديدًا لمتابعة الأبناء",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ===== Card Container for form =====
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6)),
                        BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6)),
                      ],
                    ),
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        spacing: 10,
                        key: const ValueKey('authView'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isRegister ? "إنشاء حساب لولي الأمر" : "تسجيل الدخول",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          FormBuilderTextField(
                            name: 'username',
                            decoration: InputDecoration(
                              labelText: "اسم المستخدم",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              labelStyle: style,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "أدخل اسم المستخدم";
                              }
                              if (value.length < 3) {
                                return "اسم المستخدم يجب أن يكون 3 أحرف على الأقل";
                              }
                              return null;
                            },
                          ),
                          FormBuilderTextField(
                            name: 'password',
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: "كلمة المرور",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                              labelStyle: style,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "أدخل كلمة المرور";
                              }
                              if (value.length < 6) {
                                return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
                              }
                              return null;
                            },
                          ),
                          if (isRegister) ...[
                            const SizedBox(height: 14),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: FormBuilderPhoneField(
                                name: 'phone',
                                keyboardType: TextInputType.phone,
                                defaultSelectedCountryIsoCode: 'EG',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "أدخل رقم الجوال";
                                  }
                                  if (value.length < 10) {
                                    return "رقم الجوال غير صحيح";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(isRegister ? Icons.person_add : Icons.login, size: 22),
                            onPressed: loading
                                ? null
                                : () async {
                                    try {
                                      if (_formKey.currentState!.saveAndValidate()) {
                                        setState(() => loading = true);
                                        final AppUser? user;
                                        if (isRegister) {
                                          user = await authController.registerAsParent(
                                            phone: _formKey.currentState!.value['phone'],
                                            password: _formKey.currentState!.value['password'],
                                            username: _formKey.currentState!.value['username'],
                                          );
                                        } else {
                                          user = await authController.login(
                                            username: _formKey.currentState!.value['username'],
                                            password: _formKey.currentState!.value['password'],
                                          );
                                        }
                                        if (user == null) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  isRegister
                                                      ? "يرجى استخدم اسم مستخدم اخر"
                                                      : "حدث خطأ أثناء تسجيل الدخول",
                                                ),
                                                backgroundColor: Colors.red,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        }
                                        if (user != null && user.status != 'active') {
                                          if (mounted) {
                                            QuickAlert.show(
                                              context: context,
                                              type: isRegister
                                                  ? QuickAlertType.success
                                                  : QuickAlertType.error,

                                              confirmBtnColor: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              title: isRegister
                                                  ? "تم إنشاء الحساب بنجاح"
                                                  : 'الحساب غير نشط',
                                              text: 'لتفعيل الحساب يرجى التواصل مع المسؤول',
                                              confirmBtnText: 'حسنا',
                                              onConfirmBtnTap: () {
                                                Navigator.pop(context);
                                              },
                                            ).then((value) {
                                              if (isRegister) {
                                                setState(() => isRegister = false);
                                                _formKey.currentState!.reset();
                                              }
                                            });
                                          }
                                        }

                                        if (mounted) {
                                          setState(() => loading = false);
                                        }
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        setState(() => loading = false);
                                      }
                                    }
                                  },
                            label: Text(isRegister ? "إنشاء حساب" : "تسجيل الدخول"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _formKey.currentState!.reset();
                              setState(() {
                                isRegister = !isRegister;
                              });
                            },
                            child: Text(
                              isRegister
                                  ? "لديك حساب بالفعل؟ تسجيل الدخول"
                                  : "مستخدم جديد؟ إنشاء حساب",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
