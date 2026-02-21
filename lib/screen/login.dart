import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/cubits/states/user_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_form_textfield.dart';
import 'package:training/helper/custom_glow_buttom.dart';
import 'package:training/helper/massage_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserLoaded) {
          Navigator.pushReplacementNamed(context, '/home');
        }

        if (state is UserError) {
          customDialog(
            context: context,
            title: isArabic ? 'خطأ' : 'Error',
            message: state.message,
          );
        }
      },
      child: Container(
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
                    text: isArabic ? 'مرحبًا بعودتك' : 'Welcome Back',
                    size: 22,
                  ),

                  const SizedBox(height: 30),

                  CustomFormTextField(
                    controller: _emailController,
                    labelText: isArabic ? 'البريد الإلكتروني' : 'Email address',
                    hintText: isArabic
                        ? 'أدخل بريدك الإلكتروني'
                        : 'Email address',
                    keyboardType: CustomTextFieldType.email,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  const SizedBox(height: 16),

                  CustomFormTextField(
                    controller: _passwordController,
                    labelText: isArabic ? 'كلمة المرور' : 'Password',
                    hintText: isArabic ? 'كلمة المرور' : 'Password',
                    keyboardType: CustomTextFieldType.password,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  const SizedBox(height: 24),

                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      final isLoading = state is UserLoading;

                      return CustomGlowButton(
                        title: isLoading
                            ? (isArabic ? 'جاري التحميل...' : 'Loading...')
                            : (isArabic ? 'تسجيل الدخول' : 'Login'),
                        width: double.infinity,
                        onPressed: isLoading
                            ? () {}
                            : () {
                                context.read<UserCubit>().login(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                              },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  RichText(
                    text: TextSpan(
                      text: isArabic
                          ? "ليس لديك حساب؟ "
                          : "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: isArabic
                            ? 'CustomArabicFont'
                            : 'CustomEnglishFont',
                      ),
                      children: [
                        TextSpan(
                          text: isArabic ? 'إنشاء حساب' : 'Sign Up',
                          style: const TextStyle(
                            color: Color(0xFF4FACFE),
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/register');
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
    );
  }
}
