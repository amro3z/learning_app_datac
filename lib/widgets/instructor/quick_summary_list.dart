import 'package:flutter/material.dart';
import 'package:training/data/models/dashboard_models.dart';
import 'package:training/helper/base.dart';

class QuickSummaryList extends StatelessWidget {
  final List<SummaryItem> items;

  const QuickSummaryList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    const accentColors = [
      Color(0xFF9B4DFF),
      Color(0xFF2E8BFF),
      Color(0xFF54D758),
      Color(0xFFFF8B24),
    ];

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final color = accentColors[index % accentColors.length];
        final imageSize = responsiveWidth(context, 0.13, min: 44, max: 54);
        final actionSize = responsiveWidth(context, 0.09, min: 32, max: 38);

        return Container(
          margin: EdgeInsets.only(
            bottom: index == items.length - 1
                ? 0
                : getScreenHeight(context) * 0.009,
          ),
          padding: EdgeInsets.all(getScreenWidth(context) * 0.02),
          decoration: BoxDecoration(
            color: const Color(0xFF111114),
            borderRadius: BorderRadius.circular(getScreenWidth(context) * 0.03),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(getScreenWidth(context) * 0.02),
                child: Image.network(
                  item.imageUrl,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: imageSize,
                    height: imageSize,
                    color: const Color(0xFF1E1E24),
                    child: Icon(
                      Icons.image,
                      color: Colors.white.withOpacity(.3),
                      size: imageSize * 0.42,
                    ),
                  ),
                ),
              ),
              SizedBox(width: getScreenWidth(context) * 0.025),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    defaultText(
                      context: context,
                      text: item.tag,
                      size: responsiveWidth(context, 0.022, min: 8, max: 9),
                      color: color,
                      bold: true,
                      isCenter: false,
                      maxLines: 1,
                    ),
                    SizedBox(height: getScreenHeight(context) * 0.002),
                    defaultText(
                      context: context,
                      text: item.title,
                      size: responsiveWidth(context, 0.029, min: 10, max: 12),
                      color: Colors.white,
                      bold: true,
                      isCenter: false,
                      maxLines: 1,
                    ),
                    SizedBox(height: getScreenHeight(context) * 0.003),
                    defaultText(
                      context: context,
                      text: item.subtitle,
                      size: responsiveWidth(context, 0.023, min: 8, max: 9),
                      color: Colors.white.withOpacity(.45),
                      bold: false,
                      isCenter: false,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: getScreenWidth(context) * 0.018),
              Container(
                width: actionSize,
                height: actionSize,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(getScreenWidth(context) * 0.022),
                ),
                child: Icon(item.icon, color: color, size: actionSize * 0.5),
              ),
            ],
          ),
        );
      }),
    );
  }
}
