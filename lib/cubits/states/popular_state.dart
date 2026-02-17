part of '../cubit/popular_cubit.dart';

@immutable
sealed class PopularState {}

final class PopularInitial extends PopularState {}

final class PopularLoading extends PopularState {}
final class PopularLoaded extends PopularState {
 late final List<PopularModel> popularList;
 late final List<CoursesModel> courses;
  PopularLoaded({ required this.popularList, required this.courses});
}
final class PopularError extends PopularState {
  late final String errorMessage;
  PopularError(this.errorMessage);
}