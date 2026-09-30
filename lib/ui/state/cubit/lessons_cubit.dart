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
  final Map<String, int> _progressCache = {}; 

  bool _isSaving = false;
  final LearningRepo repo;
  final EnrollmentsCubit enrollmentsCubit;

  Future<void> getLessons({bool forceRefresh = false}) async {
    emit(LessonsLoading());

    try {
      final lessons = await repo.getLessonList();

      final progress = await repo.getLessonProgressList();

      emit(LessonsLoaded(lessons: lessons, progress: progress));

      for (final p in progress.where((p) => p.status.toLowerCase() == 'completed')) {
        await enrollmentsCubit.markLessonCompleted(
          courseId: p.courseId,
          lessonId: p.lesson,
          userId: p.userId,
        );
      }

      if (!forceRefresh) {
        Future.microtask(() async {
          final freshLessons = await repo.getLessonList();

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

      final completionThreshold = (lessonDurationInSeconds * 0.75).ceil();
      final isCompleted = watchedSeconds >= completionThreshold;
      final status = isCompleted ? 'completed' : 'present';

      final key = '$userId-$courseId-$lessonId';

      LessonProgressModel? existing;
      for (final p in currentState.progress) {
        if (p.userId == userId && p.courseId == courseId && p.lesson == lessonId) {
          existing = p;
          break;
        }
      }

      final existingId = _progressCache[key] ?? existing?.id;
      
      final secondsToSave = existing == null
          ? watchedSeconds
          : (watchedSeconds > existing.watchedSeconds
              ? watchedSeconds
              : existing.watchedSeconds);

      if (existingId == null || existingId == 0) {
        final res = await repo.createLessonProgress(
          lessonId: lessonId,
          courseId: courseId,
          userId: userId,
          watchedSeconds: secondsToSave,
          status: status,
        );
        final newId = (res['data'] as Map?)?['id'];
        if (newId is int) _progressCache[key] = newId;
      } else {
        _progressCache[key] = existingId;
        await repo.updateLessonProgress(
          lessonProgressId: existingId,
          watchedSeconds: secondsToSave,
          status: status,
        );
      }

      if (isCompleted) {
        await enrollmentsCubit.markLessonCompleted(
          courseId: courseId,
          lessonId: lessonId,
          userId: userId,
        );
      }

      await getLessons(forceRefresh: true);
    } catch (e, st) {
      log('Failed to save lesson progress: $e', stackTrace: st);
    } finally {
      _isSaving = false;
    }
  }

  Future<String> getLessonFileUrl({required String fileId}) async {
    return '$baseUrl/assets/$fileId';
  }
}
