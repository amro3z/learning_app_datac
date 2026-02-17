import 'package:flutter/material.dart';
import 'package:training/data/models/categories.dart';
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
          text: category.title,
          size: 14,
          isCenter: false,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }
}
