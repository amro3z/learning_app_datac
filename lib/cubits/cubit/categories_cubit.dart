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

  Future<void> getAllCategories() async {
    emit(CategoriesLoading());
    try {
      _categories = await learningRepo.getCategoryList();
      emit(
        CategoriesLoaded(
          categories: _categories,
          selectedCategoryId: _selectedCategoryId,
        ),
      );
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

