import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';

Widget instructorCard({required String instructor , required BuildContext context}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.35),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
          ),

          CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(Icons.person, size: 22),
          ),
        ],
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          defaultText(
            context: context,
            text: "Instructor",
            size: 12,
            isCenter: false,
            color: Colors.grey,
          ),
          defaultText(text: instructor, size: 14, isCenter: false, context: context),
        ],
      ),
    ],
  );
}
