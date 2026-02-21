import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:training/cubits/cubit/categories_cubit.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/categories_state.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
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

  final TextEditingController searchController = TextEditingController();

  /// 🔥 ثابتة داخليًا (القيمة الحقيقية إنجليزي)
  final sortOptions = {
    'Recent': {'en': 'Recent', 'ar': 'الأحدث'},
    'Rating': {'en': 'Rating', 'ar': 'التقييم'},
  };

  final difficultyOptions = {
    'Easy': {'en': 'Easy', 'ar': 'سهل'},
    'Intermediate': {'en': 'Intermediate', 'ar': 'متوسط'},
    'Hard': {'en': 'Hard', 'ar': 'صعب'},
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageCubitState>(
      builder: (context, langState) {
        final languageCode = langState is LanguageCubitLoaded
            ? langState.languageCode
            : 'en';

        return BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state is! CategoriesLoaded) {
              return const SizedBox.shrink();
            }

            return CustomFormTextField(
              labelText: languageCode == 'ar'
                  ? 'ابحث عن كورسات...'
                  : 'Search courses...',
              autovalidateMode: AutovalidateMode.disabled,
              keyboardType: CustomTextFieldType.text,
              controller: searchController,
              suffixWidget: IconButton(
                icon: const Icon(
                  Icons.filter_list_sharp,
                  color: Colors.white70,
                ),
                onPressed: () => _openFiltersSheet(languageCode),
              ),
              onChanged: (value) {
                context.read<CoursesCubit>().filterCourses(
                  search: value,
                  categoryId: state.selectedCategoryId,
                  difficulty: difficulty,
                  sortBy: sortBy,
                  languageCode: languageCode,
                );
              },
            );
          },
        );
      },
    );
  }

  void _openFiltersSheet(String languageCode) {
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
                final selectedCategory = state.categories.firstWhereOrNull(
                  (c) => c.id == state.selectedCategoryId,
                );

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
                          context: context,
                          text: languageCode == 'ar' ? "الفلاتر" : "Filters",
                          size: 20,
                          bold: true,
                          isCenter: false,
                        ),
                        const SizedBox(height: 20),

                        /// SORT
                        _sectionTitle(
                          languageCode == 'ar' ? 'الترتيب' : 'Sort by',
                        ),

                        _singleSelectChips(
                          options: sortOptions.keys.toList(),
                          selected: sortBy,
                          languageCode: languageCode,
                          displayMap: sortOptions,
                          onSelected: (value) {
                            setSheetState(() {
                              sortBy = (sortBy == value) ? null : value;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        /// CATEGORY
                        _sectionTitle(
                          languageCode == 'ar' ? 'التصنيف' : 'Category',
                        ),

                        _singleSelectChips(
                          options: state.categories
                              .map((c) => c.id.toString())
                              .toList(),
                          selected: selectedCategory?.id.toString(),
                          languageCode: languageCode,
                          displayMap: {
                            for (var c in state.categories)
                              c.id.toString(): {
                                'en': c.titleEn,
                                'ar': c.titleAr,
                              },
                          },
                          onSelected: (value) {
                            context.read<CategoriesCubit>().selectCategory(
                              int.parse(value),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        /// DIFFICULTY
                        _sectionTitle(
                          languageCode == 'ar' ? 'المستوى' : 'Difficulty',
                        ),

                        _singleSelectChips(
                          options: difficultyOptions.keys.toList(),
                          selected: difficulty,
                          languageCode: languageCode,
                          displayMap: difficultyOptions,
                          onSelected: (value) {
                            setSheetState(() {
                              difficulty = (difficulty == value) ? null : value;
                            });
                          },
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// RESET
                            CustomGlowButton(
                              title: languageCode == 'ar'
                                  ? "إعادة ضبط"
                                  : "Reset",
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
                              title: languageCode == 'ar' ? "تطبيق" : "Apply",
                              width: 120,
                              onPressed: () {
                                context.read<CoursesCubit>().filterCourses(
                                  search: searchController.text,
                                  categoryId: state.selectedCategoryId,
                                  difficulty: difficulty,
                                  sortBy: sortBy,
                                  languageCode: languageCode,
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
      child: defaultText(
        context: context,
        text: text,
        size: 16,
        bold: true,
        isCenter: false,
      ),
    );
  }

  Widget _singleSelectChips({
    required List<String> options,
    required String? selected,
    required String languageCode,
    required Map<String, Map<String, String>> displayMap,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((item) {
        final isSelected = selected == item;

        return ChoiceChip(
          label: defaultText(
            context: context,
            text: displayMap[item]![languageCode]!,
            size: 14,
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
