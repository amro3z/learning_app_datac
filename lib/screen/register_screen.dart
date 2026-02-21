import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_form_textfield.dart';
import 'package:training/helper/custom_glow_buttom.dart';
import 'package:training/helper/massage_dialog.dart';
import 'package:training/services/directus_user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ApiService _api = ApiService();
  bool _loading = false;

  void _register(bool isArabic) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      customDialog(
        context: context,
        title: isArabic ? 'خطأ' : 'Error',
        message: isArabic
            ? 'كلمتا المرور غير متطابقتين'
            : 'Passwords do not match',
      );
      return;
    }

    setState(() => _loading = true);

    final result = await _api.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (!result["success"]) {
      customDialog(
        context: context,
        title: isArabic ? 'خطأ' : 'Error',
        message: result["message"],
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
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF111111), Color(0xFF151516), Color(0xFF2E2E2E)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                schoolSign(),
                const SizedBox(height: 20),

                defaultText(
                  context: context,
                  text: isArabic ? 'إنشاء حساب' : 'Create Account',
                  size: 22,
                ),

                const SizedBox(height: 24),

                CustomFormTextField(
                  controller: _firstNameController,
                  labelText: isArabic ? 'الاسم الأول' : 'First Name',
                  keyboardType: CustomTextFieldType.name,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                const SizedBox(height: 16),

                CustomFormTextField(
                  controller: _lastNameController,
                  labelText: isArabic ? 'اسم العائلة' : 'Last Name',
                  keyboardType: CustomTextFieldType.name,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                const SizedBox(height: 16),

                CustomFormTextField(
                  controller: _emailController,
                  labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                  keyboardType: CustomTextFieldType.email,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                const SizedBox(height: 16),

                CustomFormTextField(
                  controller: _passwordController,
                  labelText: isArabic ? 'كلمة المرور' : 'Password',
                  keyboardType: CustomTextFieldType.password,
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                const SizedBox(height: 16),

                CustomFormTextField(
                  controller: _confirmPasswordController,
                  labelText: isArabic
                      ? 'تأكيد كلمة المرور'
                      : 'Confirm Password',
                  keyboardType: CustomTextFieldType.password,
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                const SizedBox(height: 24),

                CustomGlowButton(
                  title: _loading
                      ? (isArabic ? 'جاري التحميل...' : 'Loading...')
                      : (isArabic ? 'إنشاء الحساب' : 'Create Account'),
                  width: double.infinity,
                  onPressed: _loading ? () {} : () => _register(isArabic),
                ),

                const SizedBox(height: 20),

                RichText(
                  text: TextSpan(
                    text: isArabic
                        ? "لديك حساب بالفعل؟ "
                        : "Already have an account? ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: isArabic
                          ? 'CustomArabicFont'
                          : 'CustomEnglishFont',
                    ),
                    children: [
                      TextSpan(
                        text: isArabic ? 'تسجيل الدخول' : 'Login',
                        style: const TextStyle(
                          color: Color(0xFF4FACFE),
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacementNamed(context, '/login');
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
    );
  }
}
