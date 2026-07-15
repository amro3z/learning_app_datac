import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';

enum CustomTextFieldType { email, name, password, number, phone, text }

class CustomFormTextField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final AutovalidateMode autovalidateMode;
  final bool obscureText;
  final CustomTextFieldType keyboardType;
  final TextEditingController? controller;
  final Widget? suffixWidget;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  const CustomFormTextField({
    super.key,
    required this.labelText,
    this.hintText,
    required this.autovalidateMode,
    required this.keyboardType,
    this.obscureText = false,
    this.controller,
    this.suffixWidget,
    this.onChanged,
    this.focusNode,
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
List<TextInputFormatter> _getInputFormatters(CustomTextFieldType type) {
    switch (type) {
      case CustomTextFieldType.name:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\u0600-\u06FF ]')),
          TextInputFormatter.withFunction((oldValue, newValue) {
            String text = newValue.text;

            text = text.replaceFirst(RegExp(r'^\s+'), '');

            text = text.replaceAll(RegExp(r'\s{2,}'), ' ');

            return TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
          }),
        ];

      case CustomTextFieldType.email:
      case CustomTextFieldType.password:
        return [FilteringTextInputFormatter.deny(RegExp(r'\s'))];

      case CustomTextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];

      case CustomTextFieldType.phone:
        return [FilteringTextInputFormatter.digitsOnly];

      case CustomTextFieldType.text:
        return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    return TextFormField(
      focusNode: widget.focusNode,
      keyboardType: _mapKeyboardType(widget.keyboardType),
      controller: widget.controller,
      obscureText: _obscureText,

      inputFormatters: _getInputFormatters(widget.keyboardType),

      validator: (v) => _validate(v, isArabic),
      autovalidateMode: widget.autovalidateMode,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: isArabic ? 'CustomArabicFont' : 'CustomEnglishFont',
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
        labelStyle: TextStyle(
          fontFamily: isArabic ? 'CustomArabicFont' : 'CustomEnglishFont',
        ),
        hintStyle: TextStyle(
          fontFamily: isArabic ? 'CustomArabicFont' : 'CustomEnglishFont',
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
      ),

      onChanged: (value) {
        final cleaned = value.replaceAll(' ', '');
        if (cleaned != value) {
          widget.controller?.text = cleaned;
          widget.controller?.selection = TextSelection.fromPosition(
            TextPosition(offset: cleaned.length),
          );
        }
        widget.onChanged?.call(cleaned);
      },
    );
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

  String? _validate(String? value, bool isArabic) {
    if (value == null || value.isEmpty) {
      return isArabic
          ? 'هذا الحقل لا يمكن أن يكون فارغًا'
          : 'This field cannot be empty';
    }

    if (value.contains(' ')) {
      return isArabic ? 'غير مسموح بمسافات' : 'Whitespace is not allowed';
    }

    switch (widget.keyboardType) {
      case CustomTextFieldType.email:
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return isArabic
              ? 'صيغة البريد الإلكتروني غير صحيحة'
              : 'The email format is incorrect';
        }
        break;
      default:
        break;
    }
    return null;
  }
}
