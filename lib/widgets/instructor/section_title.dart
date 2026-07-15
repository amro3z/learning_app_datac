import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: getScreenHeight(context) * 0.008,
        top: getScreenHeight(context) * 0.004,
      ),
      child: defaultText(
        context: context,
        text: title,
        size: responsiveWidth(context, 0.034, min: 12, max: 14),
        isCenter: false,
        maxLines: 1,
      ),
    );
  }
}
