import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/states/courses_state.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/repo/learning_repo.dart';

class CoursesCubit extends Cubit<LearnState> {
  final LearningRepo learningRepo;

  CoursesCubit({required this.learningRepo}) : super(LearnInitial());

  List<CoursesModel> _allCourses = [];
  bool isFiltering = false;

  Future<void> getAllCourses({bool forceRefresh = false}) async {
    emit(CoursesLoading());

    try {
      final local = await learningRepo.getCoursesList(
        forceRefresh: forceRefresh,
      );

      _allCourses = local.where((c) => c.status == "published").toList();

      emit(CoursesLoaded(courses: _allCourses, filteredCourses: _allCourses));

      if (!forceRefresh) {
        Future.microtask(() async {
          final fresh = await learningRepo.getCoursesList(forceRefresh: true);

          _allCourses = fresh.where((c) => c.status == "published").toList();

          emit(
            CoursesLoaded(courses: _allCourses, filteredCourses: _allCourses),
          );
        });
      }
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  void setCourses(List<CoursesModel> courses) {
    _allCourses = courses;
    emit(CoursesLoaded(courses: courses, filteredCourses: courses));
  }

  void resetFilters() {
    isFiltering = false;
    emit(CoursesLoaded(courses: _allCourses, filteredCourses: _allCourses));
  }

  void filterCourses({
    String? search,
    int? categoryId,
    String? difficulty,
    String? sortBy,
    required String languageCode,
  }) {
    List<CoursesModel> filtered = List.from(_allCourses);

    final hasSearch = search != null && search.trim().isNotEmpty;
    final hasCategory = categoryId != null;
    final hasDifficulty = difficulty != null && difficulty.trim().isNotEmpty;
    final hasSort = sortBy != null && sortBy.trim().isNotEmpty;

    if (hasSearch) {
      final query = search!.trim().toLowerCase();

      filtered = filtered.where((course) {
        return course.titleAr.toLowerCase().contains(query) ||
            course.titleEn.toLowerCase().contains(query) ||
            course.descriptionAr.toLowerCase().contains(query) ||
            course.descriptionEn.toLowerCase().contains(query);
      }).toList();
    }

    if (hasCategory) {
      filtered = filtered
          .where((course) => course.categoryID == categoryId)
          .toList();
    }

    if (hasDifficulty) {
      final levelQuery = difficulty!.trim().toLowerCase();
      filtered = filtered
          .where((course) => course.level.trim().toLowerCase() == levelQuery)
          .toList();
    }

    if (hasSort) {
      if (sortBy == 'Recent') {
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (sortBy == 'Rating') {
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
      }
    }

    isFiltering = hasSearch || hasCategory || hasDifficulty || hasSort;

    emit(CoursesLoaded(courses: _allCourses, filteredCourses: filtered));
  }
}
