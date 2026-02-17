
import 'package:training/data/models/courses.dart';

class LearnState {}

final class LearnInitial extends LearnState {}

final class CoursesLoading extends LearnState {}

final class CoursesLoaded extends LearnState {
  final List<CoursesModel> courses;
    final List<CoursesModel> filteredCourses;
  CoursesLoaded({required this.courses , required this.filteredCourses});
}

final class CoursesError extends LearnState {
  final String message;
  CoursesError(this.message);
}