import 'package:flutter/material.dart';
import 'package:training/data/models/dashboard_models.dart';
import 'package:training/helper/base.dart';

class OverviewGrid extends StatelessWidget {
  final List<OverviewStat> items;

  const OverviewGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    const accents = [
      Color(0xFF7C4DFF),
      Color(0xFF2E8BFF),
      Color(0xFF42D14A),
      Color(0xFFFF8B24),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width < 420 ? 2 : 4;
        final gap = getScreenWidth(context) * 0.02;

        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: gap,
            mainAxisSpacing: getScreenHeight(context) * 0.01,
            mainAxisExtent: responsiveHeight(
              context,
              0.2,
              min: columns == 2 ? 100 : 92,
              max: columns == 2 ? 124 : 112,
            ),
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final color = accents[index % accents.length];
            final iconBox = responsiveWidth(context, 0.09, min: 30, max: 38);

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: getScreenWidth(context) * 0.02,
                vertical: getScreenHeight(context) * 0.009,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF111114),
                borderRadius: BorderRadius.circular(
                  getScreenWidth(context) * 0.03,
                ),
                border: Border.all(color: color.withOpacity(.14)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: iconBox,
                    height: iconBox,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: color, size: iconBox * 0.55),
                  ),
                  SizedBox(height: getScreenHeight(context) * 0.006),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: defaultText(
                      text: item.value,
                      bold: true,
                      size: responsiveWidth(context, 0.045, min: 15, max: 19),
                      color: Colors.white,
                      context: context,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(height: getScreenHeight(context) * 0.002),
                  Flexible(
                    child: defaultText(
                      text: item.label,
                      bold: false,
                      size: responsiveWidth(context, 0.025, min: 8, max: 10),
                      color: Colors.white.withOpacity(.55),
                      context: context,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
