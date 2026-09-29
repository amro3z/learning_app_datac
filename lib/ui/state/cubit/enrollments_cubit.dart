import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/api/web_service.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/models/enrollments.dart';
import 'package:training/data/repo/learning_repo.dart';
import 'package:training/utils/services/enrollment_cache.dart';

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
      final cached = await EnrollmentCache.read(userId);
      final server = await learningRepo.getEnrollmentList(
        userId: userId,
        forceRefresh: forceRefresh,
      );

      // Cache prevents a pending card from reverting to "Request access" during
      // a transient/empty refresh. Directus always wins for rows it returns, so
      // pending -> approved/rejected is reflected as soon as the server returns it.
      final mergedByCourse = <int, EnrollmentModel>{
        for (final e in cached) e.courseId: e,
        for (final e in server) e.courseId: e,
      };
      final enrollments = mergedByCourse.values.toList();
      await EnrollmentCache.write(userId, enrollments);

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

  /// Creates at most one enrollment for a user/course pair.
  /// The local pending item is emitted before the POST so the card changes
  /// immediately and cannot be tapped twice while the request is in flight.
  Future<EnrollmentModel> enrollCourse({
    required int courseId,
    required String userId,
  }) async {
    final previous = state;
    if (previous is! EnrollmentsLoaded) {
      throw StateError('Enrollments must be loaded before requesting a course.');
    }

    // Never create a second row for the same user/course, regardless of status.
    final localMatches = previous.enrollments.where(
      (e) => e.courseId == courseId && e.userId == userId,
    );
    if (localMatches.isNotEmpty) return localMatches.first;

    // Check Directus too. This protects against stale UI / app restart / double tap.
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
      await EnrollmentCache.write(userId, merged);
      return existing;
    }

    // Optimistic pending state: the button changes in the same frame.
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
    await EnrollmentCache.upsert(userId, optimistic);

    try {
      final response = await webservice.enrollCourse(
        courseId: courseId,
        userId: userId,
      );
      final created = EnrollmentModel.fromJson(
        Map<String, dynamic>.from(response['data'] as Map),
      );
      final current = state;
      final courses = current is EnrollmentsLoaded ? current.courses : previous.courses;
      final currentItems = current is EnrollmentsLoaded ? current.enrollments : previous.enrollments;
      final updatedItems = [
        ...currentItems.where((e) => e.courseId != courseId),
        created,
      ];
      emit(EnrollmentsLoaded(enrollments: updatedItems, courses: courses));
      await EnrollmentCache.write(userId, updatedItems);
      return created;
    } catch (e) {
      // If the POST failed because another request already created the row,
      // re-check Directus before rolling the UI back.
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
      // Keep the cached/server-known enrollment if Directus already created it.
      // Only roll back the optimistic cache when creation truly failed.
      await EnrollmentCache.write(userId, previous.enrollments);
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
