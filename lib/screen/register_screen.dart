import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_form_textfield.dart';
import 'package:training/helper/custom_glow_buttom.dart';
import 'package:training/helper/massage_dialog.dart';
import 'package:training/screen/animated_background.dart';
import 'package:training/services/directus_user_service.dart';
import 'package:training/services/network_service.dart';
import 'package:training/widgets/grade_dropdown.dart';
import 'package:training/widgets/password_instructions.dart';

enum AccountRole { student, instructor }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _gradeController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  final _specializationController = TextEditingController();

  final _passwordStreamController =
      StreamController<Map<String, bool>>.broadcast();
  final ApiService _api = ApiService();
  final _passwordFocusNode = FocusNode();

  AccountRole _selectedRole = AccountRole.student;
  bool _loading = false;
  bool _showPasswordInstructions = false;

  late AnimationController _ambientController;
  late Animation<double> _ambientAnimation;

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(_onPasswordChanged);
    _passwordFocusNode.addListener(() {
      setState(() {
        _showPasswordInstructions = _passwordFocusNode.hasFocus;
      });
    });

    _ambientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _ambientAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut),
    );
  }

  void _onPasswordChanged() {
    _checkPassword(_passwordController.text);
  }

  void _checkPassword(String v) {
    _passwordStreamController.add({
      "length": v.length >= 8,
      "noSpace": !v.contains(" "),
      "upperLower":
          v.contains(RegExp(r'[A-Z]')) && v.contains(RegExp(r'[a-z]')),
      "special": v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    });
  }

  bool _isPasswordValid(String v) {
    return v.length >= 8 &&
        !v.contains(" ") &&
        v.contains(RegExp(r'[A-Z]')) &&
        v.contains(RegExp(r'[a-z]')) &&
        v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  bool _validateFields(bool isArabic) {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      customDialog(
        context: context,
        title: isArabic ? 'خطأ' : 'Error',
        message: isArabic
            ? 'من فضلك املأ البيانات المطلوبة'
            : 'Please fill in the required fields',
      );
      return false;
    }

    if (!_isPasswordValid(_passwordController.text.trim())) {
      customDialog(
        context: context,
        title: isArabic ? 'كلمة مرور ضعيفة' : 'Weak Password',
        message: isArabic
            ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل وتحتوي على حرف كبير وصغير ورمز خاص ولا تحتوي على مسافات'
            : 'Password must be at least 8 characters and contain uppercase, lowercase, special character, and no spaces',
      );
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      customDialog(
        context: context,
        title: isArabic ? 'خطأ' : 'Error',
        message: isArabic
            ? 'كلمتا المرور غير متطابقتين'
            : 'Passwords do not match',
      );
      return false;
    }

    if (_selectedRole == AccountRole.student) {
      if (_gradeController.text.trim().isEmpty ||
          _parentPhoneController.text.trim().isEmpty) {
        customDialog(
          context: context,
          title: isArabic ? 'خطأ' : 'Error',
          message: isArabic
              ? 'من فضلك أدخل الصف ورقم ولي الأمر'
              : 'Please enter grade and parent phone',
        );
        return false;
      }
    } else {
      if (_specializationController.text.trim().isEmpty ) {
        customDialog(
          context: context,
          title: isArabic ? 'خطأ' : 'Error',
          message: isArabic
              ? 'من فضلك أدخل التخصص والنبذة التعريفية'
              : 'Please enter specialization and bio',
        );
        return false;
      }
    }

    return true;
  }

////////////////////////////////////////////////////////////
  Future<void> _register(bool isArabic) async {
    if (!NetworkService.isConnected) {
      customDialog(
        context: context,
        title: isArabic ? 'لا يوجد اتصال' : 'No Internet',
        message: isArabic
            ? 'تحقق من اتصال الإنترنت ثم حاول مرة أخرى'
            : 'Please check your internet connection and try again',
      );
      return;
    }

    if (!_validateFields(isArabic)) return;

    setState(() => _loading = true);
    final bool isInstructor = _selectedRole == AccountRole.instructor;
    final result = await _api.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      
      isInstructor: isInstructor,
      specialization: isInstructor
          ? _specializationController.text.trim()
          : null,

      grade: !isInstructor ? _gradeController.text.trim() : null,
    );

    setState(() => _loading = false);

    if (result["success"] != true) {
      String message;
      if (result["emailExists"] == true) {
        message = isArabic
            ? 'هذا البريد الإلكتروني مستخدم بالفعل'
            : 'This email is already registered';
      } else if (result["message"] != null &&
          result["message"].toString().isNotEmpty) {
        message = result["message"];
      } else {
        message = isArabic
            ? 'حدث خطأ أثناء إنشاء الحساب'
            : 'Failed to create account';
      }

      customDialog(
        context: context,
        title: isArabic ? 'خطأ' : 'Error',
        message: message,
      );
      return;
    }

    customDialog(
      context: context,
      title: isArabic ? 'تم بنجاح' : 'Success',
      message: isArabic
          ? 'تم إنشاء الحساب بنجاح'
          : 'Account created successfully',
      onClose: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
    );
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _passwordStreamController.close();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _gradeController.dispose();
    _parentPhoneController.dispose();
    _specializationController.dispose();
    _passwordFocusNode.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  Widget _card({required Widget child}) {
    return AnimatedBuilder(
      animation: _ambientAnimation,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D2E).withOpacity(0.65),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(
                0xFF4FACFE,
              ).withOpacity(0.15 * _ambientAnimation.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF7F5AF0,
                ).withOpacity(0.08 * _ambientAnimation.value),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  Widget _roleSelector(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / 2;
          // حساب محاذاة الخلفية المتحركة بناءً على اللغة والـ Role الحالي
          final Alignment alignment = _selectedRole == AccountRole.student
              ? (isArabic ? Alignment.centerRight : Alignment.centerLeft)
              : (isArabic ? Alignment.centerLeft : Alignment.centerRight);

          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.elasticOut, // أنيميشن مطاطي سلس ومميز عند الحركة
                alignment: alignment,
                child: Container(
                  width: width - 4,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FACFE).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _roleItem(
                      isArabic: isArabic,
                      title: isArabic ? 'طالب' : 'Student',
                      icon: Icons.school_rounded,
                      selected: _selectedRole == AccountRole.student,
                      onTap: () =>
                          setState(() => _selectedRole = AccountRole.student),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _roleItem(
                      isArabic: isArabic,
                      title: isArabic ? 'مدرس' : 'Instructor',
                      icon: Icons.workspace_premium_rounded,
                      selected: _selectedRole == AccountRole.instructor,
                      onTap: () => setState(
                        () => _selectedRole = AccountRole.instructor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _roleItem({
    required bool isArabic,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.white.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white.withOpacity(0.6),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
                fontFamily: isArabic ? 'CustomArabicFont' : 'CustomEnglishFont',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentFields(bool isArabic) {
    return Column(
      key: const ValueKey(AccountRole.student),
      children: [
        AppDropdownField(
          value: _gradeController.text.isEmpty ? null : _gradeController.text,
          isArabic: isArabic,
          labelText: isArabic ? 'الصف الدراسي' : 'Grade',
          options: gradeOptions,
          onChanged: (value) {
            setState(() {
              _gradeController.text = value ?? '';
            });
          },
        ),
        SizedBox(height: getScreenHeight(context) * 0.018),
        CustomFormTextField(
          controller: _parentPhoneController,
          labelText: isArabic ? 'رقم ولي الأمر' : 'Parent Phone',
          keyboardType: CustomTextFieldType.phone,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  Widget _instructorFields(bool isArabic) {
    return Column(
      key: const ValueKey(AccountRole.instructor),
      children: [
        AppDropdownField(
          value: _specializationController.text.isEmpty
              ? null
              : _specializationController.text,
          isArabic: isArabic,
          labelText: isArabic ? 'التخصص' : 'Specialization',
          options: specializationOptions,
          onChanged: (value) {
            setState(() {
              _specializationController.text = value ?? '';
            });
          },
        ),
        SizedBox(height: getScreenHeight(context) * 0.018),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    schoolSign(),
                    SizedBox(height: getScreenHeight(context) * 0.02),
                    defaultText(
                      context: context,
                      text: isArabic ? 'إنشاء حساب جديد' : 'Create New Account',
                      size: getScreenWidth(context) * 0.056,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic
                          ? 'اختر نوع الحساب وأكمل البيانات'
                          : 'Choose account type and complete your details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 13.5,
                        fontFamily: isArabic
                            ? 'CustomArabicFont'
                            : 'CustomEnglishFont',
                      ),
                    ),
                    SizedBox(height: getScreenHeight(context) * 0.025),
                    _card(
                      child: Column(
                        children: [
                          _roleSelector(isArabic),
                          SizedBox(height: getScreenHeight(context) * 0.024),
                          CustomFormTextField(
                            controller: _firstNameController,
                            labelText: isArabic ? 'الاسم الأول' : 'First Name',
                            keyboardType: CustomTextFieldType.name,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(height: getScreenHeight(context) * 0.016),
                          CustomFormTextField(
                            controller: _lastNameController,
                            labelText: isArabic ? 'اسم العائلة' : 'Last Name',
                            keyboardType: CustomTextFieldType.name,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(height: getScreenHeight(context) * 0.016),
                          CustomFormTextField(
                            controller: _emailController,
                            labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                            keyboardType: CustomTextFieldType.email,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(height: getScreenHeight(context) * 0.016),
                          CustomFormTextField(
                            focusNode: _passwordFocusNode,
                            controller: _passwordController,
                            labelText: isArabic ? 'كلمة المرور' : 'Password',
                            keyboardType: CustomTextFieldType.password,
                            obscureText: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onChanged: (v) => _checkPassword(v),
                          ),
                          SizedBox(height: getScreenHeight(context) * 0.012),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: animation,
                                    child: child,
                                  ),
                                ),
                            child: _showPasswordInstructions
                                ? PasswordInstructions(
                                    key: const ValueKey(1),
                                    passwordStream:
                                        _passwordStreamController.stream,
                                  )
                                : const SizedBox(key: ValueKey(2)),
                          ),
                          SizedBox(height: getScreenHeight(context) * 0.016),
                          CustomFormTextField(
                            controller: _confirmPasswordController,
                            labelText: isArabic
                                ? 'تأكيد كلمة المرور'
                                : 'Confirm Password',
                            keyboardType: CustomTextFieldType.password,
                            obscureText: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(height: getScreenHeight(context) * 0.02),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            switchInCurve: Curves.easeInOutCubic,
                            switchOutCurve: Curves.easeInOutCubic,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: animation,
                                      axisAlignment: -1.0,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.0, 0.05),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                            child: _selectedRole == AccountRole.student
                                ? _studentFields(isArabic)
                                : _instructorFields(isArabic),
                          ),
                          SizedBox(height: getScreenHeight(context) * 0.026),
                          CustomGlowButton(
                            title: _loading
                                ? (isArabic ? 'جاري التحميل...' : 'Loading...')
                                : (isArabic
                                      ? 'إنشاء الحساب'
                                      : 'Create Account'),
                            width: double.infinity,
                            onPressed: _loading
                                ? () {}
                                : () => _register(isArabic),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: getScreenHeight(context) * 0.022),
                    RichText(
                      text: TextSpan(
                        text: isArabic
                            ? "لديك حساب بالفعل؟ "
                            : "Already have an account? ",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: getScreenWidth(context) * 0.035,
                          fontFamily: isArabic
                              ? 'CustomArabicFont'
                              : 'CustomEnglishFont',
                        ),
                        children: [
                          TextSpan(
                            text: isArabic ? 'تسجيل الدخول' : 'Login',
                            style: const TextStyle(
                              color: Color(0xFF4FACFE),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
