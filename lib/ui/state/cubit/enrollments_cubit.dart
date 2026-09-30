import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/api/web_service.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/models/enrollments.dart';
import 'package:training/data/repo/learning_repo.dart';

part '../states/enrollments_state.dart';

class EnrollmentsCubit extends Cubit<EnrollmentsState> {
  EnrollmentsCubit({required this.learningRepo, required this.webservice})
      : super(EnrollmentsInitial());

  final LearningRepo learningRepo;
  final LearningWebservice webservice;

  Future<void> getAllEnrollments({
    required String userId,
    bool forceRefresh = false,
    bool silent = false,
  }) async {
    final previous = state;
    try {
      if (!silent) emit(EnrollmentsLoading());
      final server = await learningRepo.getEnrollmentList(
        userId: userId,
        forceRefresh: forceRefresh,
      );

      int rank(EnrollmentModel e) => e.isApproved ? 3 : (e.isPending ? 2 : 1);
      final byCourse = <int, EnrollmentModel>{};
      for (final enrollment in server) {
        final current = byCourse[enrollment.courseId];
        if (current == null || rank(enrollment) > rank(current)) {
          byCourse[enrollment.courseId] = enrollment;
        }
      }
      final enrollments = byCourse.values.toList();

      final courses = previous is EnrollmentsLoaded
          ? previous.courses
          : await learningRepo.getCoursesList();
      emit(EnrollmentsLoaded(enrollments: enrollments, courses: courses));
    } catch (e) {
      if (silent && previous is EnrollmentsLoaded) {
        emit(previous);
      } else {
        emit(EnrollmentsError(message: e.toString()));
      }
    }
  }

  void clear() => emit(EnrollmentsInitial());

  Future<EnrollmentModel> enrollCourse({
    required int courseId,
    required String userId,
  }) async {
    final previous = state;
    if (previous is! EnrollmentsLoaded) {
      throw StateError('Enrollments must be loaded before requesting a course.');
    }

    final existingMatches = previous.enrollments.where(
      (e) => e.courseId == courseId && e.userId == userId,
    );
    if (existingMatches.isNotEmpty) return existingMatches.first;

    final serverExisting = await webservice.getEnrollmentForCourse(
      courseId: courseId,
      userId: userId,
    );
    if (serverExisting != null) {
      final existing = EnrollmentModel.fromJson(serverExisting);
      final merged = [
        ...previous.enrollments.where((e) => e.courseId != courseId),
        existing,
      ];
      emit(EnrollmentsLoaded(enrollments: merged, courses: previous.courses));
      return existing;
    }

    final optimistic = EnrollmentModel(
      id: -courseId,
      userId: userId,
      courseId: courseId,
      status: 'pending',
    );
    emit(EnrollmentsLoaded(
      enrollments: [...previous.enrollments, optimistic],
      courses: previous.courses,
    ));

    try {
      final response = await webservice.enrollCourse(
        courseId: courseId,
        userId: userId,
      );
      var created = EnrollmentModel.fromJson(
        Map<String, dynamic>.from(response['data'] as Map),
      );

      final confirmedJson = await webservice.getEnrollmentForCourse(
        courseId: courseId,
        userId: userId,
      );
      if (confirmedJson != null) {
        created = EnrollmentModel.fromJson(confirmedJson);
      }
      final current = state;
      final courses = current is EnrollmentsLoaded ? current.courses : previous.courses;
      final currentItems = current is EnrollmentsLoaded ? current.enrollments : previous.enrollments;
      final updatedItems = [
        ...currentItems.where((e) => e.courseId != courseId),
        created,
      ];
      emit(EnrollmentsLoaded(enrollments: updatedItems, courses: courses));
      return created;
    } catch (e) {

      try {
        final existingJson = await webservice.getEnrollmentForCourse(
          courseId: courseId,
          userId: userId,
        );
        if (existingJson != null) {
          final existing = EnrollmentModel.fromJson(existingJson);
          emit(EnrollmentsLoaded(
            enrollments: [
              ...previous.enrollments.where((x) => x.courseId != courseId),
              existing,
            ],
            courses: previous.courses,
          ));
          return existing;
        }
      } catch (_) {}
      emit(previous);
      rethrow;
    }
  }

  Future<void> markLessonCompleted({
    required int courseId,
    required int lessonId,
    required String userId,
  }) async {
    final current = state;
    if (current is! EnrollmentsLoaded) return;
    final matches = current.enrollments.where(
      (e) => e.courseId == courseId && e.isApproved,
    );
    if (matches.isEmpty) return;

    final enrollment = matches.first;
    if (enrollment.completedLessonIds.contains(lessonId)) return;

    final ids = {...enrollment.completedLessonIds, lessonId}.toList();
    await learningRepo.addCompletedLesson(
      enrollmentId: enrollment.id,
      completedLessonIds: ids,
    );

    final updated = current.enrollments
        .map((e) => e.id == enrollment.id ? e.copyWith(completedLessonIds: ids) : e)
        .toList();
    emit(EnrollmentsLoaded(enrollments: updated, courses: current.courses));
  }
}
