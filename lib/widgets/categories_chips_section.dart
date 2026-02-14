import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/categories_cubit.dart';
import 'package:training/cubits/states/categories_state.dart';
import 'package:training/widgets/category_chip.dart';

class CategoriesChipsSection extends StatefulWidget {
  const CategoriesChipsSection({super.key});

  @override
  State<CategoriesChipsSection> createState() => _CategoriesChipsSectionState();
}

class _CategoriesChipsSectionState extends State<CategoriesChipsSection> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading || state is CategoriesInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CategoriesError) {
          return Text(state.message);
        }

        if (state is CategoriesLoaded) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: state.categories.map((cat) {
              final isSelected = selectedCategory == cat.title;

              return CategoryChip(
                category: cat,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    selectedCategory = isSelected ? null : cat.title;
                  });
                },
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
