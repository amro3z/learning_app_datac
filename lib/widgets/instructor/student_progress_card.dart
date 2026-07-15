import 'package:flutter/material.dart';
import 'package:training/data/models/dashboard_models.dart';
import 'package:training/helper/base.dart';

class StudentProgressCard extends StatelessWidget {
  final List<ProgressStat> items;

  const StudentProgressCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFF8A4DFF), Color(0xFF54D758), Color(0xFFFF8B24)];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: getScreenHeight(context) * 0.012,
            horizontal: getScreenWidth(context) * 0.018,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF111114),
            borderRadius: BorderRadius.circular(getScreenWidth(context) * 0.035),
          ),
          child: compact
              ? Column(
                  children: List.generate(items.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == items.length - 1
                            ? 0
                            : getScreenHeight(context) * 0.01,
                      ),
                      child: _ProgressItem(
                        item: items[index],
                        color: colors[index % colors.length],
                        horizontal: true,
                      ),
                    );
                  }),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(items.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getScreenWidth(context) * 0.012,
                        ),
                        child: _ProgressItem(
                          item: items[index],
                          color: colors[index % colors.length],
                          horizontal: false,
                        ),
                      ),
                    );
                  }),
                ),
        );
      },
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final ProgressStat item;
  final Color color;
  final bool horizontal;

  const _ProgressItem({
    required this.item,
    required this.color,
    required this.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = responsiveWidth(context, 0.08, min: 28, max: 34);

    final valueBlock = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: color.withOpacity(.15),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, color: color, size: iconSize * 0.55),
        ),
        SizedBox(width: getScreenWidth(context) * 0.018),
        defaultText(
          text: item.value,
          bold: true,
          size: responsiveWidth(context, 0.043, min: 14, max: 18),
          color: Colors.white,
          context: context,
          maxLines: 1,
        ),
      ],
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        defaultText(
          text: item.label,
          size: responsiveWidth(context, 0.024, min: 8, max: 10),
          color: Colors.white.withOpacity(.66),
          context: context,
          bold: false,
          isCenter: false,
          maxLines: 2,
        ),
        SizedBox(height: getScreenHeight(context) * 0.005),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            defaultText(
              text: item.change,
              bold: true,
              size: responsiveWidth(context, 0.022, min: 8, max: 9),
              color: const Color(0xFF56E05A),
              context: context,
              maxLines: 1,
            ),
            SizedBox(width: getScreenWidth(context) * 0.01),
            Flexible(
              child: defaultText(
                context: context,
                text: 'vs last 7 days',
                size: responsiveWidth(context, 0.021, min: 7, max: 9),
                color: Colors.white.withOpacity(.30),
                bold: false,
                isCenter: false,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );

    if (horizontal) {
      return Row(
        children: [
          valueBlock,
          SizedBox(width: getScreenWidth(context) * 0.035),
          Expanded(child: details),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        valueBlock,
        SizedBox(height: getScreenHeight(context) * 0.008),
        details,
      ],
    );
  }
}
