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
}) {
  return Align(
    alignment: isCenter ? Alignment.center : Alignment.topLeft,
    child: Text(
      textAlign: align ?? TextAlign.center,
      text,
      style: TextStyle(
        fontSize: size,
        fontFamily: 'CustomFont',
        color: color,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
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
