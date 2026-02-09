import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/models/enrollments.dart';
import 'package:training/data/repo/learning_repo.dart';

part '../states/enrollments_state.dart';

class EnrollmentsCubit extends Cubit<EnrollmentsState> {
  EnrollmentsCubit({required this.learningRepo}) : super(EnrollmentsInitial());
  final LearningRepo learningRepo;
  late List<EnrollmentModel> enrollments;
  late List<CoursesModel> courses;
  Future<List<EnrollmentModel>> getAllEnrollments() async {
    try {
      emit(EnrollmentsLoading());
      final enrollments = await learningRepo.getEnrollmentList();
      final courses = await learningRepo.getCoursesList();
      emit(EnrollmentsLoaded(enrollments: enrollments , courses: courses));
      return enrollments;
    } catch (e) {
      emit(EnrollmentsError(message: e.toString()));
      return [];
    }
  }
}
