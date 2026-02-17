import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:training/cubits/cubit/categories_cubit.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
import 'package:training/cubits/states/categories_state.dart';
import 'package:training/helper/custom_form_textfield.dart';
import 'package:training/helper/custom_glow_buttom.dart';
import 'package:training/helper/base.dart';

class CoursesSearchBar extends StatefulWidget {
  const CoursesSearchBar({super.key});

  @override
  State<CoursesSearchBar> createState() => _CoursesSearchBarState();
}

class _CoursesSearchBarState extends State<CoursesSearchBar> {
  String? sortBy;
  String? difficulty;

  final sortOptions = ['Recent', 'Rating'];
  final difficultyOptions = ['Easy', 'intermediate', 'Hard'];

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is! CategoriesLoaded) {
          return const SizedBox.shrink();
        }

        return CustomFormTextField(
          labelText: 'Search courses...',
          // hintText: 'Search courses...',
          autovalidateMode: AutovalidateMode.disabled,
          keyboardType: CustomTextFieldType.text,
          controller: searchController,
          suffixWidget: IconButton(
            icon: const Icon(Icons.filter_list_sharp, color: Colors.white70),
            onPressed: () => _openFiltersSheet(),
          ),
          onChanged: (value) {
            context.read<CoursesCubit>().filterCourses(
              search: value,
              categoryId: state.selectedCategoryId,
              difficulty: difficulty,
              sortBy: sortBy,
            );
          },
        );
      },
    );
  }

  void _openFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state is! CategoriesLoaded) {
              return const SizedBox.shrink();
            }

            return StatefulBuilder(
              builder: (context, setSheetState) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        defaultText(
                          text: "Filters",
                          size: 20,
                          bold: true,
                          isCenter: false,
                        ),
                        const SizedBox(height: 20),

                        /// SORT
                        _sectionTitle('Sort by'),
                        _singleSelectChips(
                          options: sortOptions,
                          selected: sortBy,
                          onSelected: (v) {
                            setSheetState(() {
                              sortBy = (sortBy == v) ? null : v;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        /// CATEGORY (FIXED)
                        _sectionTitle('Category'),
                        _singleSelectChips(
                          options: state.categories
                              .map((c) => c.title)
                              .toList(),
                          selected: state.categories
                              .firstWhereOrNull(
                                (c) => c.id == state.selectedCategoryId,
                              )
                              ?.title,
                          onSelected: (v) {
                            final selected = state.categories.firstWhere(
                              (c) => c.title == v,
                            );

                            context.read<CategoriesCubit>().selectCategory(
                              selected.id,
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        /// DIFFICULTY
                        _sectionTitle('Difficulty'),
                        _singleSelectChips(
                          options: difficultyOptions,
                          selected: difficulty,
                          onSelected: (v) {
                            setSheetState(() {
                              difficulty = (difficulty == v) ? null : v;
                            });
                          },
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// RESET
                            CustomGlowButton(
                              title: "Reset",
                              width: 120,
                              onPressed: () {
                                setSheetState(() {
                                  sortBy = null;
                                  difficulty = null;
                                });

                                context.read<CategoriesCubit>().selectCategory(
                                  null,
                                );

                                context.read<CoursesCubit>().resetFilters();

                                searchController.clear();
                              },
                            ),

                            /// APPLY
                            CustomGlowButton(
                              title: "Apply",
                              width: 120,
                              onPressed: () {
                                context.read<CoursesCubit>().filterCourses(
                                  search: searchController.text,
                                  categoryId: state.selectedCategoryId,
                                  difficulty: difficulty,
                                  sortBy: sortBy,
                                );

                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: defaultText(text: text, size: 16, bold: true, isCenter: false),
    );
  }

  Widget _singleSelectChips({
    required List<String> options,
    required String? selected,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((item) {
        final isSelected = selected == item;

        return ChoiceChip(
          label: defaultText(
            text: item,
            size: 14,
            isCenter: true,
            color: isSelected ? Colors.white : Colors.white70,
          ),
          selected: isSelected,
          onSelected: (_) => onSelected(item),
          selectedColor: const Color(0xFF3BA9FF),
          backgroundColor: Colors.white.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
        );
      }).toList(),
    );
  }
}
