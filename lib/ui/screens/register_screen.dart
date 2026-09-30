import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/ui/state/cubit/language_cubit.dart';
import 'package:training/ui/state/states/language_cubit_state.dart';
import 'package:training/ui/core/base.dart';
import 'package:training/ui/core/custom_form_textfield.dart';
import 'package:training/ui/core/custom_glow_buttom.dart';
import 'package:training/ui/core/massage_dialog.dart';
import 'package:training/ui/screens/animated_background.dart';
import 'package:training/utils/services/directus_user_service.dart';
import 'package:training/utils/services/network_service.dart';
import 'package:training/ui/widgets/grade_dropdown.dart';
import 'package:training/ui/widgets/password_instructions.dart';

part 'register/register_logic.dart';
part 'register/register_widgets.dart';

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
              padding: EdgeInsets.symmetric(horizontal: getScreenWidth(context) * 0.06154, vertical: getScreenHeight(context) * 0.02000),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    schoolSign(context),
                    SizedBox(height: getScreenHeight(context) * 0.02),
                    defaultText(
                      context: context,
                      text: isArabic ? 'إنشاء حساب جديد' : 'Create New Account',
                      size: getScreenWidth(context) * 0.056,
                    ),
                    SizedBox(height: getScreenHeight(context) * 0.01000),
                    Text(
                      isArabic
                          ? 'اختر نوع الحساب وأكمل البيانات'
                          : 'Choose account type and complete your details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: getScreenWidth(context) * 0.03462,
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
                                    passwordStream:
                                        _passwordStreamController.stream,
                                  )
                                : SizedBox(),
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
                            style: TextStyle(
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
