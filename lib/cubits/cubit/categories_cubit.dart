import 'package:bloc/bloc.dart';
import 'package:training/cubits/states/categories_state.dart';
import 'package:training/data/models/categories.dart';
import 'package:training/data/repo/learning_repo.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({required this.learningRepo}) : super(CategoriesInitial());

  final LearningRepo learningRepo;

  List<CategoriesModel> _categories = [];
  int? _selectedCategoryId;

  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> getAllCategories({bool forceRefresh = false}) async {
    emit(CategoriesLoading());

    try {
      // 🔹 1) رجع local فورًا
      final local = await learningRepo.getCategoryList(
        forceRefresh: forceRefresh,
      );

      _categories = local;

      emit(
        CategoriesLoaded(
          categories: _categories,
          selectedCategoryId: _selectedCategoryId,
        ),
      );

      // 🔹 2) background refresh
      if (!forceRefresh) {
        Future.microtask(() async {
          final fresh = await learningRepo.getCategoryList(forceRefresh: true);

          _categories = fresh;

          emit(
            CategoriesLoaded(
              categories: _categories,
              selectedCategoryId: _selectedCategoryId,
            ),
          );
        });
      }
    } catch (e) {
      emit(CategoriesError(message: e.toString()));
    }
  }

  void selectCategory(int? categoryId) {
    _selectedCategoryId = _selectedCategoryId == categoryId ? null : categoryId;

    emit(
      CategoriesLoaded(
        categories: _categories,
        selectedCategoryId: _selectedCategoryId,
      ),
    );
  }
}
