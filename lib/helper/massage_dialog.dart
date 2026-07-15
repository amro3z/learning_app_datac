import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_glow_buttom.dart';

void customDialog({
  required BuildContext context,
  required String title,
  required String message,
  void Function()? onClose,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
          final langState = context.read<LanguageCubit>().state;
      final isArabic =
          langState is LanguageCubitLoaded && langState.languageCode == 'ar';
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: getScreenWidth(context) * 0.10256, vertical: getScreenHeight(context) * 0.03000),
        backgroundColor: Color(0xFF191919),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: getScreenWidth(context) * 0.8,
          padding: EdgeInsets.all(getScreenWidth(context) * 0.04615),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.black, Color(0xFF191919)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onClose != null) onClose();
                  },
                )
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  defaultText(
                    text: title,
                    size: getScreenWidth(context) * 0.05,
                    bold: true,
                    color: Colors.white,
                    context: context,
                  ),
                  SizedBox(height: getScreenHeight(context) * 0.02),
                  defaultText(
                    text: message,
                    size: getScreenWidth(context) * 0.04,
                    color: Colors.white,
                    context: context,
                  ),
                  SizedBox(height: getScreenHeight(context) * 0.033),
CustomGlowButton(
                    title: isArabic ? 'حسنا' : 'OK',
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onClose != null) onClose();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
