import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    context.read<UserCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listenWhen: (prev, curr) => prev is UserLoading && curr is UserLoaded,
      listener: (context, state) {
        if (state is UserLoaded) {
          Navigator.pushReplacementNamed(context, '/home');
        }

        if (state is UserError) {
          customDialog(
            context: context,
            title: 'Error',
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  schoolSign(),
                  const SizedBox(height: 20),
                  defaultText(
                    text: 'Welcome Back',
                    size: 22,
                    color: Colors.white,
                    bold: true,
                  ),
                  const SizedBox(height: 30),

                  /// Email
                  CustomFormTextField(
                    controller: _emailController,
                    labelText: 'Email address',
                    hintText: 'Email address',
                    keyboardType: CustomTextFieldType.email,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    suffixWidget: const Icon(Icons.email, color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  /// Password
                  CustomFormTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Password',
                    keyboardType: CustomTextFieldType.password,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: true,
                    suffixWidget: const Icon(Icons.lock, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  /// Login Button (loading-aware)
                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      final isLoading = state is UserLoading;

                      return CustomGlowButton(
                        title: isLoading ? 'Loading...' : 'Login',
                        width: double.infinity,
                        onPressed: state is UserLoading
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

                  /// Register
                  RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
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
