import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/data/models/categories.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final CategoriesModel category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';

    final title = languageCode == 'ar' ? category.titleAr : category.titleEn;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? category.color : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? category.color : Colors.white.withOpacity(0.08),
          ),
        ),
        child: defaultText(
          context: context,
          text: title,
          size: 14,
          isCenter: false,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }
}
