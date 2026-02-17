import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';

class CustomGlowButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double? textSize;
  final double? width;

  const CustomGlowButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.textSize,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getScreenHeight(context) * 0.053,
      width: width ?? getScreenWidth(context) * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF8F5BFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onPressed,
        child: defaultText(
          text: title,
          size: textSize ?? getScreenHeight(context) * 0.02,
          bold: true,
        ),
      ),
    );
  }
}
