import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/models/lesson_progress.dart';
import 'package:training/data/models/lessons.dart';
import 'package:training/data/repo/learning_repo.dart';

part '../states/lessons_state.dart';

class LessonsCubit extends Cubit<LessonsState> {
  LessonsCubit({required this.repo}) : super(LessonsInitial());
  final LearningRepo repo;
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
}
