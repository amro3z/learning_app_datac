part of '../cubit/lessons_cubit.dart';

@immutable
sealed class LessonsState {}

final class LessonsInitial extends LessonsState {}

final class LessonsLoading extends LessonsState {}

final class LessonsLoaded extends LessonsState {
  final List<LessonModel> lessons;
final List<LessonProgressModel> progress;
  LessonsLoaded({required this.lessons, required this.progress});
}

final class LessonsError extends LessonsState {
  final String message;
  LessonsError({required this.message});
}