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
            width: getScreenWidth(context) * 0.07692,
            height: getScreenHeight(context) * 0.03750,
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
            width: getScreenWidth(context) * 0.08974,
            height: getScreenHeight(context) * 0.04375,
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
      SizedBox(width: getScreenWidth(context) * 0.02051),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          defaultText(
            context: context,
            text: "Instructor",
            size: getScreenWidth(context) * 0.03077,
            isCenter: false,
            color: Colors.grey,
          ),
          defaultText(text: instructor, size: getScreenWidth(context) * 0.03590, isCenter: false, context: context),
        ],
      ),
    ],
  );
}
