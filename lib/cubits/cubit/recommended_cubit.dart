import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/models/Recommend.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/repo/learning_repo.dart';

part '../states/recommended_state.dart';

class RecommendedCubit extends Cubit<RecommendedState> {
  RecommendedCubit({required this.learningRepo}) : super(RecommendedInitial());

  final LearningRepo learningRepo;
Future<List<RecommendModel>> getRecommendedList({
    bool forceRefresh = false,
  }) async {
    emit(RecommendedLoading());
    try {
      final local = await learningRepo.getRecommendedList(
        forceRefresh: forceRefresh,
      );

      final courses = await learningRepo.getCoursesList();

      emit(RecommendedLoaded(recommends: local, courses: courses));

      if (!forceRefresh) {
        Future.microtask(() async {
          final fresh = await learningRepo.getRecommendedList(
            forceRefresh: true,
          );

          emit(RecommendedLoaded(recommends: fresh, courses: courses));
        });
      }

      return local;
    } catch (e) {
      emit(RecommendedError(message: e.toString()));
      return [];
    }
  }

}
