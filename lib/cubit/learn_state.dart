
import 'package:training/data/models/courses_model.dart';

class LearnState {}

final class LearnInitial extends LearnState {}

final class Loading extends LearnState {}

final class LearnLoaded extends LearnState {
  final List<CoursesModel> courses;
  LearnLoaded({required this.courses});
}

final class Error extends LearnState {
  final String message;
  Error(this.message);
}