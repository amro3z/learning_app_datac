import 'package:flutter/material.dart';
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
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        backgroundColor: Color(0xFF191919),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: getScreenWidth(context) * 0.8,
          padding: const EdgeInsets.all(18.0),
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
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
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
                    title: 'ok',
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
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
