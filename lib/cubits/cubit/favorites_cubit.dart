import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/api/web_service.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/models/favorites.dart';
import 'package:training/data/repo/learning_repo.dart';

part '../states/favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({required this.webservice, required this.repo})
    : super(FavoritesInitial());
  final LearningWebservice webservice;
  final LearningRepo repo;

  Future<void> getFavoritesList({required String userId}) async {
    emit(FavoritesLoading());
    try {
      final favoritesList = await repo.getFavoriteList(userId: userId);

      final courses = await repo.getCoursesList();

      emit(FavoritesLoaded(favoritesList: favoritesList, courses: courses));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
  void clear() {
    emit(FavoritesInitial());
  }
  Future<void> addToFavorites({
    required int courseId,
    required String userId,
  }) async {
    await webservice.postFavorite(courseId: courseId, userId: userId);

    await getFavoritesList(userId: userId);
  }


Future<void> deleteFavorite({
    required int favoriteID,
    required String userId,
  }) async {
    try {
      await webservice.deleteFavorite(favoriteID: favoriteID);

      await getFavoritesList(userId: userId);
    } catch (e) {
      emit(FavoritesError('Failed to remove from favorites: $e'));
    }
  }
}
