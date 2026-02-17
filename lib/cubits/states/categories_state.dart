
import 'package:training/data/models/categories.dart';

class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoriesModel> categories;
  final int? selectedCategoryId;

  CategoriesLoaded({required this.categories, this.selectedCategoryId});

  CategoriesLoaded copyWith({
    List<CategoriesModel>? categories,
    int? selectedCategoryId,
  }) {
    return CategoriesLoaded(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId,
    );
  }
}

class CategoriesError extends CategoriesState {
  final String message;
  CategoriesError({required this.message});
}
