import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:hidaya/utils/constants.dart';
import 'package:hidaya/utils/app_theme.dart';

import '../../controllers/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isRegister = false;
  bool loading = false;
  bool _obscureText = true;
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _animationController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.read(authControllerProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: TextButton(
            onPressed: () {
              _formKey.currentState!.reset();
              setState(() {
                isRegister = !isRegister;
              });
            },
            child: RichText(
              text: TextSpan(
                text: isRegister ? "لديك حساب بالفعل؟ " : "مستخدم جديد؟ ",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                children: [
                  TextSpan(
                    text: isRegister ? "تسجيل الدخول" : "إنشاء حساب",
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            child: Column(
              children: [
                // Header Section
                _buildHeader(),

                // Form Section
                Expanded(child: _buildFormSection(authController)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
            child: Column(
              children: [
                // Logo with enhanced styling
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      'assets/icons/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.mosque,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // App Title
                Text(
                  AppConstants.appTitle,
                  style: AppTheme.islamicTitleStyle.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // Description
                Text(
                  isRegister
                      ? "أنشئ حساباً جديداً لمتابعة تعليم أبنائك"
                      : "سجل دخولك لمتابعة تعليم أبنائك",
                  textAlign: TextAlign.center,
                  style: AppTheme.arabicTextStyle.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormSection(AuthController authController) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                     const SizedBox(height: 10),
                    // Form Title
                    Text(
                      isRegister
                          ? "أدخل بياناتك لإنشاء حساب"
                          : "أدخل بياناتك لتسجيل الدخول",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Form
                    FormBuilder(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Username Field
                          _buildFormField(
                            name: 'username',
                            label: "اسم المستخدم",
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppConstants.requiredField;
                              }
                              if (value.length < 3) {
                                return "اسم المستخدم يجب أن يكون 3 أحرف على الأقل";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Password Field
                          _buildFormField(
                            name: 'password',
                            label: "كلمة المرور",
                            icon: Icons.lock_outline,
                            obscureText: _obscureText,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppConstants.requiredField;
                              }
                              if (value.length < 6) {
                                return AppConstants.passwordTooShort;
                              }
                              return null;
                            },
                          ),

                          // Registration Fields
                          if (isRegister) ...[
                            const SizedBox(height: 10),

                            _buildFormField(
                              name: 'name',
                              label: "اسم ولي الأمر",
                              icon: Icons.person_add_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppConstants.requiredField;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),

                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: FormBuilderPhoneField(
                                name: 'phone',
                                keyboardType: TextInputType.phone,
                                scrollPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                defaultSelectedCountryIsoCode: 'EG',
                                decoration: InputDecoration(
                                  hintText: "رقم الجوال",
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 5,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppConstants.requiredField;
                                  }
                                  if (value.length < 10) {
                                    return AppConstants.invalidPhone;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],

                          const SizedBox(height: 15),

                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              icon: loading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      isRegister
                                          ? Icons.person_add
                                          : Icons.login,
                                      size: 24,
                                    ),
                              onPressed: loading
                                  ? null
                                  : () => _handleSubmit(authController),
                              label: Text(
                                isRegister ? "إنشاء حساب" : "تسجيل الدخول",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ), // Toggle Button
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required String name,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return FormBuilderTextField(
      name: name,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Future<void> _handleSubmit(AuthController authController) async {
    try {
      if (_formKey.currentState!.saveAndValidate()) {
        setState(() => loading = true);

        final AppUser? user;
        if (isRegister) {
          user = await authController.registerAsParent(
            phone: _formKey.currentState!.value['phone'],
            name: _formKey.currentState!.value['name'],
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
                      ? "يرجى استخدام اسم مستخدم آخر"
                      : "حدث خطأ أثناء تسجيل الدخول",
                ),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }

        if (user != null && user.status != 'active') {
          if (mounted) {
            QuickAlert.show(
              context: context,
              type: isRegister ? QuickAlertType.success : QuickAlertType.error,
              confirmBtnColor: AppTheme.primaryColor,
              title: isRegister ? "تم إنشاء الحساب بنجاح" : 'الحساب غير نشط',
              text: 'لتفعيل الحساب يرجى التواصل مع المسؤول',
              confirmBtnText: 'حسناً',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
