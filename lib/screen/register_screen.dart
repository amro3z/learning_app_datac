import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  void _register() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    if (password != confirmPassword) {
      customDialog(
        context: context,
        title: 'Error',
        message: 'Passwords do not match',
      );
      return;
    }

    setState(() => _loading = true);

    final result = await _api.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: password,
    );

    setState(() => _loading = false);

    if (!result["success"]) {
      customDialog(
        context: context,
        title: 'Error',
        message: result["message"],
      );
      return;
    }

    customDialog(
      context: context,
      title: 'Success',
      message: 'Account created successfully',
      onClose: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
    );
  
  }

  @override
  Widget build(BuildContext context) {
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
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  schoolSign(),

                  const SizedBox(height: 20),
                  defaultText(
                    text: 'Create Account',
                    size: 22,
                    color: Colors.white,
                    bold: true,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: CustomFormTextField(
                          controller: _firstNameController,
                          labelText: 'First Name',
                          hintText: 'First Name',
                          keyboardType: CustomTextFieldType.name,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomFormTextField(
                          controller: _lastNameController,
                          labelText: 'Last Name',
                          hintText: 'Last Name',
                          keyboardType: CustomTextFieldType.name,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  CustomFormTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Email',
                    keyboardType: CustomTextFieldType.email,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  const SizedBox(height: 16),

                  CustomFormTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Password',
                    keyboardType: CustomTextFieldType.password,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  const SizedBox(height: 16),

                  CustomFormTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Confirm Password',
                    keyboardType: CustomTextFieldType.password,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  const SizedBox(height: 24),

                  CustomGlowButton(
                    title: _loading ? 'Loading...' : 'Create Account',
                    width: double.infinity,
                    onPressed: _loading ? () {} : _register,
                  ),

                  const SizedBox(height: 20),

                  RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: 'Login',
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
      ),
    );
  }
}
