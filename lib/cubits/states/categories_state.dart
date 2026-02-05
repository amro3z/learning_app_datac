part of '../cubit/categories_cubit.dart';

@immutable
sealed class CategoriesState {}

final class CategoriesInitial extends CategoriesState {}

final class CategoriesLoading extends CategoriesState {}

final class CategoriesLoaded extends CategoriesState {
  final List<CategoriesModel> categories;
  CategoriesLoaded({required this.categories});
}

final class CategoriesError extends CategoriesState {
  final String message;
  CategoriesError({required this.message});
}
