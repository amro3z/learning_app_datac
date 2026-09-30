part of '../register_screen.dart';

extension _RegisterLogic on _RegisterScreenState {
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
}
