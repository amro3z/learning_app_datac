import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';

class DashboardHeader extends StatelessWidget {
  final String instructorName;
  final String avatarUrl;

  const DashboardHeader({
    super.key,
    required this.instructorName,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = responsiveWidth(context, 0.12, min: 40, max: 52);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              defaultText(
                context: context,
                text: 'Hello, $instructorName 👋',
                size: responsiveWidth(context, 0.052, min: 18, max: 22),
                isCenter: false,
                maxLines: 1,
              ),
              SizedBox(height: getScreenHeight(context) * 0.004),
              defaultText(
                context: context,
                text: "Here's what's happening with your courses",
                size: responsiveWidth(context, 0.029, min: 10, max: 12),
                color: Colors.white.withOpacity(.45),
                bold: false,
                isCenter: false,
                maxLines: 2,
              ),
            ],
          ),
        ),
        SizedBox(width: getScreenWidth(context) * 0.025),
        Container(
          width: avatarSize,
          height: avatarSize,
          padding: EdgeInsets.all(getScreenWidth(context) * 0.005),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF7C4DFF), width: 2),
          ),
          child: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: const Color(0xFF1B1B1F),
          ),
        ),
      ],
    );
  }
}
