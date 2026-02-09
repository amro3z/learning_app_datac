part of '../cubit/favorites_cubit.dart';

@immutable
sealed class FavoritesState {}

final class FavoritesInitial extends FavoritesState {}

final class FavoritesLoading extends FavoritesState {}

final class FavoritesLoaded extends FavoritesState {
  final List<FavoritesModel> favoritesList;
  final List<CoursesModel> courses;

  FavoritesLoaded({required this.favoritesList, required this.courses});
}

final class FavoritesError extends FavoritesState {
  final String message;

  FavoritesError(this.message);
}