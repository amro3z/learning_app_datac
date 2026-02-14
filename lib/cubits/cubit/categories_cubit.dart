import 'package:bloc/bloc.dart';
import 'package:training/cubits/states/categories_state.dart';
import 'package:training/data/repo/learning_repo.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({required this.learningRepo}) : super(CategoriesInitial());

  final LearningRepo learningRepo;

  Future<void> getAllCategories() async {
    emit(CategoriesLoading());
    try {
      final categories = await learningRepo.getCategoryList();

      emit(CategoriesLoaded(categories: categories, selectedCategoryId: null));
    } catch (e) {
      emit(CategoriesError(message: e.toString()));
    }
  }

  void selectCategory(int? categoryId) {
    if (state is CategoriesLoaded) {
      final current = state as CategoriesLoaded;

      emit(current.copyWith(selectedCategoryId: categoryId));
    }
  }
}
