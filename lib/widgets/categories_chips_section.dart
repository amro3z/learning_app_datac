import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/categories_cubit.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
import 'package:training/cubits/states/categories_state.dart';
import 'package:training/widgets/category_chip.dart';

class CategoriesChipsSection extends StatelessWidget {
  const CategoriesChipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is! CategoriesLoaded) {
          return const SizedBox.shrink();
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: state.categories.map((cat) {
            final isSelected = state.selectedCategoryId == cat.id;

return CategoryChip(
              category: cat,
              isSelected: isSelected,
              onTap: () {
                final categoriesCubit = context.read<CategoriesCubit>();
                final coursesCubit = context.read<CoursesCubit>();

                if (isSelected) {
                  // إلغاء الفلترة
                  categoriesCubit.selectCategory(null);
                  coursesCubit.resetFilters();
                } else {
                  categoriesCubit.selectCategory(cat.id);
                  coursesCubit.filterCourses(categoryId: cat.id);
                }
              },
            );

          }).toList(),
        );
      },
    );
  }
}
