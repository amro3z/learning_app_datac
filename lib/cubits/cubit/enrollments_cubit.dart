import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/api/web_service.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/models/enrollments.dart';
import 'package:training/data/models/lesson_progress.dart';
import 'package:training/data/models/lessons.dart';
import 'package:training/data/repo/learning_repo.dart';

part '../states/enrollments_state.dart';

class EnrollmentsCubit extends Cubit<EnrollmentsState> {
  EnrollmentsCubit({required this.learningRepo, required this.webservice}) : super(EnrollmentsInitial());
  final LearningRepo learningRepo;
  final LearningWebservice webservice;
  late List<EnrollmentModel> enrollments;
  late List<CoursesModel> courses;
  Future<List<EnrollmentModel>> getAllEnrollments() async {
    try {
      emit(EnrollmentsLoading());
      final enrollments = await learningRepo.getEnrollmentList();
      final courses = await learningRepo.getCoursesList();
      emit(EnrollmentsLoaded(enrollments: enrollments, courses: courses));
      return enrollments;
    } catch (e) {
      emit(EnrollmentsError(message: e.toString()));
      return [];
    }
  }

  Future<void> enrollCourse({
    required int courseId,
    required String userId,
  }) async {
    emit(EnrollmentsSubmitting());

    try {
      await webservice.enrollCourse(courseId: courseId, userId: userId);

      await getAllEnrollments(); 
    } catch (e) {
      emit(EnrollmentsError( message: 'Failed to enroll: $e'));
    }
  }

  double calculateCourseProgress({
    required List<LessonModel> lessons,
    required List<LessonProgressModel> progressList,
    required int courseId,
  }) {
    final courseLessons = lessons.where((l) => l.courseId == courseId).toList();

    final Map<int, int> watchedMap = {
      for (var p in progressList)
        if (p.courseId == courseId) p.lesson: p.watchedSeconds,
    };

    int totalDuration = 0;
    int totalWatched = 0;

    for (var lesson in courseLessons) {
      totalDuration += lesson.duration;
      totalWatched += watchedMap[lesson.id] ?? 0;
    }

    if (totalDuration == 0) return 0;

    return totalWatched / totalDuration;
  }

Future<void> updateCourseProgress({
    required int enrollmentId,
    required double progress,
  }) async {
    await learningRepo.updateEnrollmentProgress(
      enrollmentId: enrollmentId,
      progressPercent: progress,
    );

    await getAllEnrollments();
  }

}
