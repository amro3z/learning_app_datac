import 'dart:developer';

import 'package:training/data/api/web_service.dart';
import 'package:training/data/models/courses.dart';

class LearningRepo {
  late final LearningWebservice learningWebService;
  LearningRepo({ required this.learningWebService});
Future<List<CoursesModel>> getCoursesList() async {
    final response = await learningWebService.getCoursesList();
    log(response.toString());
    final List data = response['data'] ?? [];

    return data.map((course) => CoursesModel.fromJson(course)).toList();
  }

}