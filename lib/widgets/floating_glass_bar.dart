import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';

class FloatingGlassBar extends StatefulWidget {
  const FloatingGlassBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  State<FloatingGlassBar> createState() => _FloatingGlassBarState();
}

class _FloatingGlassBarState extends State<FloatingGlassBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;

    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);

    final isCompact = screenWidth < 360;

    final horizontalMargin = screenWidth * (isCompact ? 0.025 : 0.035);
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    final barHeight = responsiveHeight(
      context,
      isCompact ? 0.078 : 0.083,
      min: 66,
      max: 76,
    );

    final items = <_NavItemData>[
      _NavItemData(
        selectedIcon: Icons.dashboard_rounded,
        unselectedIcon: Icons.dashboard_outlined,
        label: isArabic ? 'لوحة التحكم' : 'Dashboard',
      ),
      _NavItemData(
        selectedIcon: Icons.menu_book_rounded,
        unselectedIcon: Icons.menu_book_outlined,
        label: isArabic ? 'دوراتي' : 'My Courses',
      ),
      _NavItemData(
        selectedIcon: Icons.add_circle_rounded,
        unselectedIcon: Icons.add_circle_outline_rounded,
        label: isArabic ? 'إنشاء دورة' : 'Create Course',
      ),
      _NavItemData(
        selectedIcon: Icons.video_library_rounded,
        unselectedIcon: Icons.video_library_outlined,
        label: isArabic ? 'إدارة الدورات' : 'Manage Courses',
      ),
    ];

    return Positioned(
      left: horizontalMargin,
      right: horizontalMargin,
      bottom: safeBottom + screenHeight * 0.01,
      child: SizedBox(
        height: barHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.055),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _AnimatedBlurBackground(controller: _backgroundController),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: const SizedBox.expand(),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.055),
                  color: const Color(0xFF15151C).withOpacity(0.58),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.14),
                    width: 1,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.012,
                  vertical: screenHeight * 0.005,
                ),
                child: Stack(
                  children: [
                    _buildSelectedIndicator(
                      count: items.length,
                      isArabic: isArabic,
                      screenWidth: screenWidth,
                    ),
                    Row(
                      children: List.generate(
                        items.length,
                        (index) => _buildNavItem(
                          context: context,
                          data: items[index],
                          index: index,
                          isCompact: isCompact,
                          isArabic: isArabic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedIndicator({
    required int count,
    required bool isArabic,
    required double screenWidth,
  }) {
    final step = 2.0 / (count - 1);

    final targetX = isArabic
        ? 1.0 - (widget.currentIndex * step)
        : -1.0 + (widget.currentIndex * step);

    return AnimatedAlign(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: Alignment(targetX, 0),
      child: FractionallySizedBox(
        widthFactor: 1 / count,
        heightFactor: 1,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.008),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.035),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5838D7), Color(0xFF7548F4)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7048F4).withOpacity(0.38),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required _NavItemData data,
    required int index,
    required bool isCompact,
    required bool isArabic,
  }) {
    final selected = widget.currentIndex == index;

    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);

    final iconSize = responsiveWidth(
      context,
      isCompact ? 0.046 : 0.05,
      min: 18,
      max: 21,
    );

    final labelSize = responsiveWidth(
      context,
      isCompact ? 0.018 : 0.021,
      min: 7,
      max: 9.5,
    );

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
        onTap: () => widget.onItemSelected(index),
        child: SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.003,
              vertical: screenHeight * 0.002,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? data.selectedIcon : data.unselectedIcon,
                  size: iconSize,
                  color: selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.48),
                ),
                SizedBox(height: screenHeight * 0.003),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      data.label,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: isArabic
                            ? 'CustomArabicFont'
                            : 'CustomEnglishFont',
                        fontSize: labelSize,
                        height: 1,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? Colors.white
                            : Colors.white.withOpacity(0.48),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBlurBackground extends StatelessWidget {
  const _AnimatedBlurBackground({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final angle = controller.value * 2 * math.pi;

        final firstX = math.sin(angle) * 35;
        final firstY = math.cos(angle) * 15;

        final secondX = math.cos(angle) * 40;
        final secondY = math.sin(angle) * 18;

        final thirdX = math.sin(angle + math.pi) * 30;
        final thirdY = math.cos(angle + math.pi) * 15;

        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFF111117)),
            Positioned(
              left: -35 + firstX,
              top: -45 + firstY,
              child: _BlurBlob(
                size: getScreenWidth(context) * 0.6,
                color: const Color(0xFF6336E8),
              ),
            ),
            Positioned(
              right: -45 + secondX,
              bottom: -55 + secondY,
              child: _BlurBlob(
                size: getScreenWidth(context) * 0.65,
                color: const Color(0xFF2F61D7),
              ),
            ),
            Positioned(
              left: getScreenWidth(context) * 0.25 + thirdX,
              bottom: -60 + thirdY,
              child: _BlurBlob(
                size: getScreenWidth(context) * 0.45,
                color: const Color(0xFF9B3FD8),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.45),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
  });

  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String label;
}
