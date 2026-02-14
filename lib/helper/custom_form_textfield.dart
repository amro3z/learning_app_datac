import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomTextFieldType { email, name, password, number, phone, text }

class CustomFormTextField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final AutovalidateMode autovalidateMode;
  final bool obscureText;
  final CustomTextFieldType keyboardType;
  final TextEditingController? controller;
  final TextDirection textDirection;
  final Widget? suffixWidget;
  final Function(String)? onChanged;
  const CustomFormTextField({
    super.key,
    required this.labelText,
     this.hintText,
    required this.autovalidateMode,
    required this.keyboardType,
    this.obscureText = false,
    this.controller,
    this.textDirection = TextDirection.ltr,
    this.suffixWidget,
    this.onChanged,
  });

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  TextInputType _mapKeyboardType(CustomTextFieldType type) {
    switch (type) {
      case CustomTextFieldType.email:
        return TextInputType.emailAddress;
      case CustomTextFieldType.name:
        return TextInputType.name;
      case CustomTextFieldType.number:
        return TextInputType.number;
      case CustomTextFieldType.phone:
        return TextInputType.phone;
      case CustomTextFieldType.password:
        return TextInputType.visiblePassword;
      case CustomTextFieldType.text:
        return TextInputType.text;
    }
  }

  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }

    switch (widget.keyboardType) {
      case CustomTextFieldType.email:
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'The email format is incorrect';
        }
        break;

      case CustomTextFieldType.name:
        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
          return 'Please enter a valid name';
        }
        break;

      case CustomTextFieldType.number:
        if (!RegExp(r'^\d+$').hasMatch(value)) {
          return 'Please enter numbers only';
        }
        break;

      case CustomTextFieldType.phone:
        if (!RegExp(r'^\d{11}$').hasMatch(value)) {
          return 'Please enter an 11-digit phone number';
        }
        break;

      case CustomTextFieldType.password:
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        break;

      case CustomTextFieldType.text:
        if (value.trim().isEmpty) {
          return 'This field cannot be empty';
        }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: _mapKeyboardType(widget.keyboardType),
      controller: widget.controller,
      obscureText: _obscureText,
      validator: _validate,
      inputFormatters: [
        if (widget.keyboardType == CustomTextFieldType.phone) ...[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ] else if (widget.keyboardType == CustomTextFieldType.number) ...[
          FilteringTextInputFormatter.digitsOnly,
        ] else if (widget.keyboardType == CustomTextFieldType.email) ...[
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
        ] else if (widget.keyboardType == CustomTextFieldType.password) ...[
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9#@&%$]')),
        ],
      ],

      obscuringCharacter: '•',
      autovalidateMode: widget.autovalidateMode,
      textDirection: widget.textDirection,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'CustomFont',
      ),
      decoration: InputDecoration(
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
              )
            : widget.suffixWidget,
        hintText: widget.hintText,
        labelText: widget.labelText,
        hintTextDirection: widget.textDirection,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'CustomFont',
        ),
        hintStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'CustomFont',
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 0.7,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: const BorderSide(color: Colors.red, width: 0.7),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: const BorderSide(color: Colors.red, width: 0.7),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(color: Colors.blueAccent, width: 0.7),
        ),
        errorStyle: TextStyle(fontFamily: 'CustomFont', fontSize: 12),
      ),
      onChanged: widget.onChanged,
    );
  }
}
