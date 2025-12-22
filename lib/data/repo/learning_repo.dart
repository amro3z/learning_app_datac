import 'package:training/data/api/web_service.dart';
import 'package:training/data/models/courses_model.dart';

class LearningRepo {
  late final LearningWebservice characterWebService;
  LearningRepo({required this.characterWebService});
  Future<List<CoursesModel>> getCoursesList() async {
    final response = await characterWebService.getCoursesList();
    List<CoursesModel> courses = (response['results'] as List)
        .map((course) => CoursesModel.fromJson(course))
        .toList();
    return courses;
  }
}