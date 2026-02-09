import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/models/popular.dart';
import 'package:training/data/repo/learning_repo.dart';

part '../states/popular_state.dart';

class PopularCubit extends Cubit<PopularState> {
  PopularCubit({ required this.learningRepo}) : super(PopularInitial());
  final LearningRepo learningRepo ;
  Future<void> getPopularList() async {
    emit(PopularLoading());
    try {
      final popularList = await learningRepo.getPopularList();
        final courses = await learningRepo.getCoursesList();
      emit(PopularLoaded(popularList: popularList, courses: courses));
    } catch (e) {
      emit(PopularError(e.toString()));
    }
  }
}
