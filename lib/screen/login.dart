import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_form_textfield.dart';
import 'package:training/helper/custom_glow_buttom.dart';
import 'package:training/helper/massage_dialog.dart';
import 'package:training/services/directus_user_service.dart';
import 'package:training/data/local/auth_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _api = ApiService();

  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    /// 1) LOGIN -> get access_token
    final loginResult = await _api.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!loginResult["success"]) {
      customDialog(
        context: context,
        title: 'Error',
        message: loginResult["message"],
      );
      return;
    }

    final String token = loginResult["access_token"];

    /// 2) GET CURRENT USER -> get userId
    final userResult = await _api.getCurrentUser(accessToken: token);

    if (!userResult["success"]) {
      customDialog(
        context: context,
        title: 'Error',
        message: 'Failed to load user data',
      );
      return;
    }

    final String userId = userResult["user"]["id"];

    /// 3) SAVE token + userId
    await AuthStorage.saveAuthData(token: token, userId: userId);

    if (!mounted) return;

    customDialog(
      context: context,
      title: 'Success',
      message: 'Login successful',
    );

    /// 4) NAVIGATE
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    suffixIcon: const Icon(Icons.email, color: Colors.grey),
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
                    suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  /// Login Button
                  CustomGlowButton(
                    title: _loading ? 'Loading...' : 'Login',
                    width: double.infinity,
                    onPressed: _loading ? () {} : _login,
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
