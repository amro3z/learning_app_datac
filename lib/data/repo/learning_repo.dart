import 'dart:developer';
import 'package:training/data/api/web_service.dart';
import 'package:training/data/models/Recommend.dart';
import 'package:training/data/models/categories.dart';
import 'package:training/data/models/courses.dart';
import 'package:training/data/models/enrollments.dart';
import 'package:training/data/models/favorites.dart';
import 'package:training/data/models/instructor.dart';
import 'package:training/data/models/lesson_progress.dart';
import 'package:training/data/models/lessons.dart';
import 'package:training/data/models/popular.dart';

class LearningRepo {
  final LearningWebservice learningWebService;

  LearningRepo({required this.learningWebService});

  Future<List<CoursesModel>> getCoursesList() async {
    final response = await learningWebService.getCoursesList();

    final List data = response['data'] ?? [];
    return data
        .map((course) => CoursesModel.fromJson(course))
        .toList();
  }

  Future<List<CategoriesModel>> getCategoryList() async {
    final response = await learningWebService.getCategoryList();

    final List data = response['data'] ?? [];
    return data
        .map((category) => CategoriesModel.fromJson(category))
        .toList();
  }

  Future<List<LessonModel>> getLessonList() async {
    final response = await learningWebService.getLessonList();

    final List data = response['data'] ?? [];
    return data
        .map((lesson) => LessonModel.fromJson(lesson))
        .toList();
  }

   Future<List<LessonProgressModel>> getLessonProgressList() async {
    final response = await learningWebService.getLessonProgressList();
    final List data = response['data'] ?? [];
    return data
        .map((progress) => LessonProgressModel.fromJson(progress))
        .toList();
  }


  Future<List<InstructorModel>> getInstructorList() async {
    final response = await learningWebService.getInstructorList();

    final List data = response['data'] ?? [];
    return data
        .map((instructor) => InstructorModel.fromJson(instructor))
        .toList();
  }

 
  Future<List<EnrollmentModel>> getEnrollmentList({
    required String userId,
  }) async {
    final data = await learningWebService.getEnrollmentList(userId: userId);

    final List list = data["data"];

    return list.map((e) => EnrollmentModel.fromJson(e)).toList();
  }

  Future<List<FavoritesModel>> getFavoriteList({required String userId}) async {
    final data = await learningWebService.getFavoriteList(userId: userId);

    final List list = data["data"];

    return list.map((e) => FavoritesModel.fromJson(e)).toList();
  }

    Future<List<RecommendModel>> getRecommendedList() async {
    final response = await learningWebService.getRecommendedList();

    final List data = response['data'] ?? [];
    return data.map((recommended) => RecommendModel.fromJson(recommended)).toList();
  }

     Future<List<PopularModel>> getPopularList() async {
    final response = await learningWebService.getPopularList();

    final List data = response['data'] ?? [];
    return data
        .map((popular) => PopularModel.fromJson(popular))
        .toList();
  }

Future<void> updateEnrollmentProgress({
    required int enrollmentId,
    required double progressPercent,
  }) async {
    await learningWebService.updateEnrollmentProgress(
      enrollmentId: enrollmentId,
      progressPercent: progressPercent,
    );
  }
Future<void> updateLessonProgress({
    required int lessonProgressId,
    required int watchedSeconds,
    required String status,
  }) async {
    await learningWebService.updateLessonProgress(
      lessonProgressId: lessonProgressId,
      watchedSeconds: watchedSeconds,
      status: status,
    );
  }



}
