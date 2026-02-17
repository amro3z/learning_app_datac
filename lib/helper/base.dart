import 'package:flutter/material.dart';

get getScreenWidth =>
    (BuildContext context) => MediaQuery.of(context).size.width;

get getScreenHeight =>
    (BuildContext context) => MediaQuery.of(context).size.height;

Widget defaultText({
  required String text,
  required double size,
  bool isCenter = true,
  Color? color,
  bool bold = true,
  TextAlign? align,

  int maxLines = 2,
  TextOverflow overflow = TextOverflow.ellipsis,
}) {
  return Text(
    text,
    textAlign: align ?? TextAlign.center,
    maxLines: maxLines,
    overflow: overflow,
    style: TextStyle(
      fontSize: size,
      fontFamily: 'CustomFont',
      color: color ?? Colors.white,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}

Widget schoolSign() {
  return Container(
    width: 70,
    height: 70,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4FACFE), Color(0xFF8F5BFF)],
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: const Icon(Icons.school, color: Colors.white, size: 34),
  );
}

Widget progressBar({
  required double progress, // من 0.0 لـ 1.0
  double height = 10,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * progress,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4FACFE), // أزرق
                    Color(0xFF7B61FF), // بنفسجي
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget ratingWidget({required double value}) {
  return Row(
    children: [
      ...List.generate(
        5,
        (index) => Icon(
          index < value.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        ),
      ),
      const SizedBox(width: 6),
      defaultText(text: value.toString(), bold: false, size: 12),
    ],
  );
}
