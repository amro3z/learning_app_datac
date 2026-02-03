import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/states/courses_state.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/repo/learning_repo.dart';

class CoursesCubit extends Cubit<LearnState> {
  LearningRepo learningRepo;
  late List<CoursesModel> courses;
  CoursesCubit({required this.learningRepo}) : super(LearnInitial());
  Future<List<CoursesModel>> getAllCourses() async {
    try {
      emit(Loading());
      final courses = await learningRepo.getCoursesList();
      emit(LearnLoaded(courses: courses));
      return courses;
    } catch (e) {
      emit(Error(e.toString()));
      return [];
    }
  }
}
