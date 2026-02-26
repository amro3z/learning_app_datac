import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/models/popular.dart';
import 'package:training/data/repo/learning_repo.dart';

part '../states/popular_state.dart';

class PopularCubit extends Cubit<PopularState> {
  PopularCubit({ required this.learningRepo}) : super(PopularInitial());
  final LearningRepo learningRepo ;
Future<List<PopularModel>> getPopularList({bool forceRefresh = false}) async {
    emit(PopularLoading());
    try {
      final local = await learningRepo.getPopularList(
        forceRefresh: forceRefresh,
      );

      final courses = await learningRepo.getCoursesList();

      emit(PopularLoaded(popularList: local, courses: courses));

      if (!forceRefresh) {
        Future.microtask(() async {
          final fresh = await learningRepo.getPopularList(forceRefresh: true);

          emit(PopularLoaded(popularList: fresh, courses: courses));
        });
      }

      return local;
    } catch (e) {
      emit(PopularError(e.toString()));
      return [];
    }
  }
}
