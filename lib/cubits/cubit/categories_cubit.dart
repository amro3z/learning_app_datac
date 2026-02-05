import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/models/categories.dart';
import 'package:training/data/repo/learning_repo.dart';

part '../states/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({required this.learningRepo}) : super(CategoriesInitial());
  LearningRepo learningRepo;
  late List<CategoriesModel> categoriesList;
  Future<void> getAllCategories() async {
    emit(CategoriesLoading());
    try {
      categoriesList = await learningRepo.getCategoryList();
      emit(CategoriesLoaded(categories: categoriesList));
    } catch (e) {
      emit(CategoriesError(message: e.toString()));
    }
  }
}
