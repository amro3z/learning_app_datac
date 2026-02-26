import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/models/lesson_progress.dart';
import 'package:training/data/models/lessons.dart';
import 'package:training/data/repo/learning_repo.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';

part '../states/lessons_state.dart';

class LessonsCubit extends Cubit<LessonsState> {
  LessonsCubit({required this.repo, required this.enrollmentsCubit})
    : super(LessonsInitial());

  final LearningRepo repo;
  final EnrollmentsCubit enrollmentsCubit;

Future<void> getLessons({bool forceRefresh = false}) async {
    emit(LessonsLoading());

    try {
      final lessons = await repo.getLessonList(forceRefresh: forceRefresh);

      final progress = await repo.getLessonProgressList();

      emit(LessonsLoaded(lessons: lessons, progress: progress));

      if (!forceRefresh) {
        Future.microtask(() async {
          final freshLessons = await repo.getLessonList(forceRefresh: true);

          final freshProgress = await repo.getLessonProgressList();

          emit(LessonsLoaded(lessons: freshLessons, progress: freshProgress));
        });
      }
    } catch (e) {
      emit(LessonsError(message: e.toString()));
    }
  }

  Future<void> updateLessonProgress({
    required int lessonId,
    required int courseId,
    required String userId,
    required int watchedSeconds,
  }) async {
    try {
      final currentState = state;
      if (currentState is! LessonsLoaded) return;

      final lesson = currentState.lessons.firstWhere((l) => l.id == lessonId);

      final lessonDurationInSeconds = lesson.duration * 60;

      final bool isCompleted = watchedSeconds >= (lessonDurationInSeconds - 60);

      final status = isCompleted ? "completed" : "present";

      final progress = currentState.progress.firstWhere(
        (p) =>
            p.lesson == lessonId &&
            p.courseId == courseId &&
            p.userId == userId,
      );

      await repo.updateLessonProgress(
        lessonProgressId: progress.id,
        watchedSeconds: watchedSeconds,
        status: status,
      );
      await getLessons();

      await calculateAndUpdateCourseProgress(
        courseId: courseId,
        userId: userId,
      );
    } catch (e) {
      emit(LessonsError(message: e.toString()));
    }
  }

  Future<void> calculateAndUpdateCourseProgress({
    required int courseId,
    required String userId,
  }) async {
    final currentState = state;
    if (currentState is! LessonsLoaded) return;

    final courseLessons = currentState.lessons
        .where((l) => l.courseId == courseId)
        .toList();

    if (courseLessons.isEmpty) return;

    int completedCount = 0;

    for (final lesson in courseLessons) {
      final progress = currentState.progress.firstWhere(
        (p) =>
            p.lesson == lesson.id &&
            p.courseId == courseId &&
            p.userId == userId,
        orElse: () => LessonProgressModel.empty(),
      );

      final lessonDurationInSeconds = lesson.duration * 60;

      final bool isCompleted =
          progress.watchedSeconds >= (lessonDurationInSeconds - 60);

      if (isCompleted) {
        completedCount++;
      }
    }

    final double percent = completedCount / courseLessons.length;

    final enrollmentsState = enrollmentsCubit.state;

    if (enrollmentsState is EnrollmentsLoaded) {
      final enrollment = enrollmentsState.enrollments.firstWhere(
        (e) => e.courseId == courseId,
      );

      await enrollmentsCubit.updateCourseProgress(
        userId: userId,
        enrollmentId: enrollment.id,
        progress: percent,
      );
    }
  }
}
