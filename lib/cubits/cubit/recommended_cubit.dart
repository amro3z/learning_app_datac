import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:training/data/models/Recommend.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/repo/learning_repo.dart';

part '../states/recommended_state.dart';

class RecommendedCubit extends Cubit<RecommendedState> {
  RecommendedCubit({required this.learningRepo}) : super(RecommendedInitial());

  final LearningRepo learningRepo;
Future<List<RecommendModel>> getRecommendedList() async {
    emit(RecommendedLoading());
    try {
      final recommends = await learningRepo.getRecommendedList();
      final courses = await learningRepo.getCoursesList();
      emit(RecommendedLoaded(recommends: recommends, courses: courses));
      return recommends;
    } catch (e) {
      emit(RecommendedError(message: e.toString()));
      return [];
    }
  }

}
