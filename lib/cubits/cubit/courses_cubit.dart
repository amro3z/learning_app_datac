import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/states/courses_state.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/repo/learning_repo.dart';

class CoursesCubit extends Cubit<LearnState> {
  final LearningRepo learningRepo;

  CoursesCubit({required this.learningRepo}) : super(LearnInitial());

  List<CoursesModel> _allCourses = [];
  bool isFiltering = false;

  Future<void> getAllCourses() async {
    emit(CoursesLoading());

    try {
      final courses = await learningRepo.getCoursesList();

      /// 🔥 published فقط
      _allCourses = courses.where((c) => c.status == "published").toList();

      isFiltering = false;

      emit(CoursesLoaded(courses: _allCourses, filteredCourses: _allCourses));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

void filterCourses({
    String? search,
    String? difficulty,
    String? sortBy,
    int? categoryId,
  }) {
    List<CoursesModel> result = List.from(_allCourses);

    if (search != null && search.isNotEmpty) {
      result = result
          .where((c) => c.title.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }

    if (categoryId != null) {
      result = result.where((c) => c.categoryID == categoryId).toList();
    }

    if (difficulty != null) {
      result = result.where((c) => c.level == difficulty).toList();
    }

    if (sortBy != null) {
      if (sortBy == "Recent") {
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (sortBy == "Rating") {
        result.sort((a, b) => b.rating.compareTo(a.rating));
      }
    }

    isFiltering =
        result.length != _allCourses.length ||
        search != null && search.isNotEmpty ||
        categoryId != null ||
        difficulty != null ||
        sortBy != null;

    emit(CoursesLoaded(courses: _allCourses, filteredCourses: result));
  }



void resetFilters() {
    isFiltering = false;

    emit(CoursesLoaded(courses: _allCourses, filteredCourses: _allCourses));
  }

}
