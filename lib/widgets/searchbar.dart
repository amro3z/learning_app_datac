import 'package:flutter/material.dart';

class CoursesSearchBar extends StatefulWidget {
  const CoursesSearchBar({super.key});

  @override
  State<CoursesSearchBar> createState() => _CoursesSearchBarState();
}

class _CoursesSearchBarState extends State<CoursesSearchBar> {
  /// ===== Filters State (nullable) =====
  String? sortBy;
  String? category;
  String? difficulty;

  final sortOptions = ['Recent', 'Popular', 'Rating'];
  final categoryOptions = [
    'Development',
    'Design',
    'Business',
    'AI',
    'Marketing',
    'Languages',
  ];
  final difficultyOptions = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white, fontFamily: 'CustomFont'),
              decoration: InputDecoration(
                hintText: 'Search courses...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_sharp, color: Colors.white70),
            onPressed: _openFiltersSheet,
          ),
        ],
      ),
    );
  }

  /// ===== Bottom Sheet =====
  void _openFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F0F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

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

                  _sectionTitle('Category'),
                  _singleSelectChips(
                    options: categoryOptions,
                    selected: category,
                    onSelected: (v) {
                      setSheetState(() {
                        category = (category == v) ? null : v;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

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

                  Center(
                    child: TextButton(
                      onPressed: () {
                        setSheetState(() {
                          sortBy = null;
                          category = null;
                          difficulty = null;
                        });
                      },
                      child: const Text(
                        'Reset Filters',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// ===== UI Helpers =====

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
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
          label: Text(item),
          selected: isSelected,
          onSelected: (_) => onSelected(item),
          selectedColor: const Color(0xFF3BA9FF),
          backgroundColor: Colors.white.withOpacity(0.08),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
        );
      }).toList(),
    );
  }
}
