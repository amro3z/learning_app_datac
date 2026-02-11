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

  /// ===============================
  /// تحميل الدروس + البروجرس
  /// ===============================
  Future<void> getLessons() async {
    emit(LessonsLoading());

    try {
      final lessons = await repo.getLessonList();
      final progress = await repo.getLessonProgressList();

      emit(LessonsLoaded(lessons: lessons, progress: progress));
    } catch (e) {
      emit(LessonsError(message: e.toString()));
    }
  }

  /// ===============================
  /// تحديث بروجرس الليسن + الكورس
  /// ===============================
Future<void> updateLessonProgress({
    required int lessonId,
    required int courseId,
    required String userId,
    required int watchedSeconds,
    required String status,
  }) async {
    try {
      final currentState = state;

      if (currentState is! LessonsLoaded) return;

      final existing = currentState.progress.firstWhere(
        (p) =>
            p.lesson == lessonId &&
            p.courseId == courseId &&
            p.userId == userId,
      );

      await repo.updateLessonProgress(
        lessonProgressId: existing.id, // ✅ أهم نقطة
        watchedSeconds: watchedSeconds,
        status: status,
      );

      await getLessons();
    } catch (e) {
      emit(LessonsError(message: e.toString()));
    }
  }


}
