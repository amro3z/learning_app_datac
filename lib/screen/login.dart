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
import 'package:training/services/network_service.dart';

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
      listenWhen: (previous, current) {
        if (previous is UserLoading && current is UserLoaded) return true;
        if (current is UserError) return true;
        return false;
      },
      listener: (context, state) {
        if (state is UserLoaded) {
          Navigator.pushReplacementNamed(context, '/home');
        }

        if (state is UserError) {
          String message;

          if (state.message == "INVALID_CREDENTIALS") {
            message = isArabic
                ? "البريد الإلكتروني أو كلمة المرور غير صحيحة"
                : "Email or password is incorrect";
          } else if (state.message == "EMAIL_NOT_FOUND") {
            message = isArabic
                ? "البريد الإلكتروني غير موجود"
                : "Email not found";
          } else if (state.message == "NETWORK_ERROR") {
            message = isArabic ? "مشكلة في الاتصال بالإنترنت" : "Network error";
          } else {
            message = isArabic ? "فشل تسجيل الدخول" : "Login failed";
          }

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          customDialog(
            context: context,
            title: isArabic ? 'خطأ' : 'Error',
            message: message,
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
                  SizedBox(height: getScreenHeight(context) * 0.022),

                  defaultText(
                    context: context,
                    text: isArabic ? 'مرحبًا بعودتك' : 'Welcome Back',
                    size: getScreenWidth(context) * 0.055,
                  ),

                  SizedBox(height: getScreenHeight(context) * 0.033),

                  CustomFormTextField(
                    controller: _emailController,
                    labelText: isArabic ? 'البريد الإلكتروني' : 'Email address',
                    hintText: isArabic
                        ? 'أدخل بريدك الإلكتروني'
                        : 'Email address',
                    keyboardType: CustomTextFieldType.email,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  SizedBox(height: getScreenHeight(context) * 0.018),

                  CustomFormTextField(
                    controller: _passwordController,
                    labelText: isArabic ? 'كلمة المرور' : 'Password',
                    hintText: isArabic ? 'كلمة المرور' : 'Password',
                    keyboardType: CustomTextFieldType.password,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  SizedBox(height: getScreenHeight(context) * 0.027),

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
                                if (!NetworkService.isConnected) {
                                  customDialog(
                                    context: context,
                                    title: isArabic
                                        ? 'لا يوجد اتصال'
                                        : 'No Internet',
                                    message: isArabic
                                        ? 'تحقق من اتصال الإنترنت ثم حاول مرة أخرى'
                                        : 'Please check your internet connection and try again',
                                  );
                                  return;
                                }

                                context.read<UserCubit>().login(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                              },
                      );
                    },
                  ),

                  SizedBox(height: getScreenHeight(context) * 0.022),

                  RichText(
                    text: TextSpan(
                      text: isArabic
                          ? "ليس لديك حساب؟ "
                          : "Don't have an account? ",
                      style: TextStyle(
                        fontSize: getScreenWidth(context) * 0.035,
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
