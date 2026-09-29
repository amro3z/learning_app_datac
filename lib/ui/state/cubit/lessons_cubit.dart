import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/api/api_constant.dart';
import 'package:training/data/models/lesson_progress.dart';
import 'package:training/data/models/lessons.dart';
import 'package:training/data/repo/learning_repo.dart';
import 'package:training/ui/state/cubit/enrollments_cubit.dart';

part '../states/lessons_state.dart';

class LessonsCubit extends Cubit<LessonsState> {
  LessonsCubit({required this.repo, required this.enrollmentsCubit})
    : super(LessonsInitial());
  final Map<String, int> _progressCache = {}; // 👈 مهم

  bool _isSaving = false;
  final LearningRepo repo;
  final EnrollmentsCubit enrollmentsCubit;

  Future<void> getLessons({bool forceRefresh = false}) async {
    emit(LessonsLoading());

    try {
      final lessons = await repo.getLessonList();
      // final lessons = await repo.getLessonList(forceRefresh: forceRefresh);

      final progress = await repo.getLessonProgressList();

      emit(LessonsLoaded(lessons: lessons, progress: progress));

      if (!forceRefresh) {
        Future.microtask(() async {
          final freshLessons = await repo.getLessonList();
          // final freshLessons = await repo.getLessonList(forceRefresh: true);

          final freshProgress = await repo.getLessonProgressList();

          emit(LessonsLoaded(lessons: freshLessons, progress: freshProgress));
        });
      }
      log(lessons.toString());
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
    if (_isSaving) return;
    _isSaving = true;

    try {
      final currentState = state;
      if (currentState is! LessonsLoaded) return;

      final lesson = currentState.lessons.firstWhere((l) => l.id == lessonId);

      final lessonDurationInSeconds = lesson.duration * 60;

      final isCompleted = watchedSeconds >= (lessonDurationInSeconds - 60);

      final status = isCompleted ? "completed" : "present";

      final key = "$userId-$courseId-$lessonId";

      final cachedId = _progressCache[key];

      if (cachedId == null) {
        // 🟢 CREATE
        final res = await repo.createLessonProgress(
          lessonId: lessonId,
          courseId: courseId,
          userId: userId,
          watchedSeconds: watchedSeconds,
          status: status,
        );

        final newId = res['data']['id'];
        _progressCache[key] = newId;
      } else {
        // 🔵 UPDATE
        await repo.updateLessonProgress(
          lessonProgressId: cachedId,
          watchedSeconds: watchedSeconds,
          status: status,
        );
      }

      // 🔥 مهم جدًا: نجيب أحدث داتا
      await getLessons(forceRefresh: true);

      if (isCompleted) {
        await enrollmentsCubit.markLessonCompleted(
          courseId: courseId,
          lessonId: lessonId,
          userId: userId,
        );
      }
    } catch (e) {
      print("❌ ERROR: $e");
    } finally {
      _isSaving = false;
    }
  }

  Future<String> getLessonFileUrl({required String fileId}) async {
    return '$baseUrl/assets/$fileId';
  }
}
