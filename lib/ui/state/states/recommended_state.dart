part of '../cubit/recommended_cubit.dart';

@immutable
sealed class RecommendedState {}

final class RecommendedInitial extends RecommendedState {}

final class RecommendedLoading extends RecommendedState {}

final class RecommendedLoaded extends RecommendedState {
 late final  List<RecommendModel> recommends;
late final List<CoursesModel> courses;
  RecommendedLoaded({required this.recommends , required this.courses});
}

final class RecommendedError extends RecommendedState {
  final String message;

  RecommendedError({required this.message});
}