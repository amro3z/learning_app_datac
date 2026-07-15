import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';

get getScreenWidth =>
    (BuildContext context) => MediaQuery.sizeOf(context).width;

get getScreenHeight =>
    (BuildContext context) => MediaQuery.sizeOf(context).height;

double responsiveWidth(
  BuildContext context,
  double factor, {
  double? min,
  double? max,
}) {
  final value = getScreenWidth(context) * factor;
  return value.clamp(min ?? 0, max ?? double.infinity).toDouble();
}

double responsiveHeight(
  BuildContext context,
  double factor, {
  double? min,
  double? max,
}) {
  final value = getScreenHeight(context) * factor;
  return value.clamp(min ?? 0, max ?? double.infinity).toDouble();
}

Widget defaultText({
  required BuildContext context,
  required String text,
  required double size,
  bool isCenter = true,
  Color? color,
  bool bold = true,
  TextAlign? align,
  int maxLines = 2,
  TextOverflow overflow = TextOverflow.ellipsis,
}) {
  final langState = context.watch<LanguageCubit>().state;
  final isArabic =
      langState is LanguageCubitLoaded && langState.languageCode == 'ar';

  return Text(
    text,
    textAlign: align ??
        (isCenter
            ? TextAlign.center
            : (isArabic ? TextAlign.right : TextAlign.left)),
    maxLines: maxLines,
    overflow: overflow,
    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    style: TextStyle(
      fontSize: size,
      height: 1.2,
      fontFamily: isArabic ? 'CustomArabicFont' : 'CustomEnglishFont',
      color: color ?? Colors.white,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}

Widget schoolSign(BuildContext context) {
  final size = responsiveWidth(context, 0.18, min: 58, max: 78);

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4FACFE), Color(0xFF8F5BFF)],
      ),
      borderRadius: BorderRadius.circular(size * 0.31),
    ),
    child: Icon(
      Icons.school,
      color: Colors.white,
      size: size * 0.48,
    ),
  );
}

Widget progressBar({
  required BuildContext context,
  required double progress,
  double? height,
}) {
  final barHeight = height ?? responsiveHeight(context, 0.012, min: 7, max: 11);

  return ClipRRect(
    borderRadius: BorderRadius.circular(barHeight),
    child: Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(barHeight),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF7B61FF)],
                ),
                borderRadius: BorderRadius.circular(barHeight),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget ratingWidget({
  required double value,
  required BuildContext context,
}) {
  final iconSize = responsiveWidth(context, 0.035, min: 12, max: 18);

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ...List.generate(
        5,
        (index) => Icon(
          index < value.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: iconSize,
        ),
      ),
      SizedBox(width: getScreenWidth(context) * 0.015),
      defaultText(
        text: value.toString(),
        bold: false,
        size: responsiveWidth(context, 0.035, min: 12, max: 16),
        context: context,
      ),
    ],
  );
}
