// lib/data/repo/learning_repo.dart
import 'dart:convert';
import 'dart:developer';

import 'package:training/data/api/api_constant.dart';
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
import 'package:training/services/tokens/api_client.dart';

class LearningRepo {
  final LearningWebservice learningWebService;
  final ApiClient _api = ApiClient();

  LearningRepo({required this.learningWebService});

  // ================= COURSES =================

  Future<List<CoursesModel>> getCoursesList({
    bool forceRefresh = false,
  }) async {
    final response = await learningWebService.getCoursesList();
    final List data = response['data'] ?? [];

    return data
        .map((course) => CoursesModel.fromJson(course))
        .toList();
  }

  // ================= CATEGORIES =================

  Future<List<CategoriesModel>> getCategoryList({
    bool forceRefresh = false,
  }) async {
    final response = await learningWebService.getCategoryList();
    final List data = response['data'] ?? [];

    return data
        .map((category) => CategoriesModel.fromJson(category))
        .toList();
  }

  // ================= LESSONS =================

  Future<List<LessonModel>> getLessonList() async {
    final response = await learningWebService.getLessonList();
    final List data = response['data'] ?? [];

    return data.map((lesson) => LessonModel.fromJson(lesson)).toList();
  }

  // ================= INSTRUCTORS =================

  Future<List<InstructorModel>> getInstructorList({
    bool forceRefresh = false,
  }) async {
    final response = await learningWebService.getInstructorList();
    final List data = response['data'] ?? [];

    final instructors = data
        .map((instructor) => InstructorModel.fromJson(instructor))
        .toList();

    log('Fetched ${instructors.length} instructors from API');
    return instructors;
  }

  // ================= ENROLLMENTS =================

  Future<List<EnrollmentModel>> getEnrollmentList({
    required String userId,
    bool forceRefresh = false,
  }) async {
    final response = await learningWebService.getEnrollmentList(
      userId: userId,
    );
    final List data = response['data'] ?? [];

    return data
        .map((enrollment) => EnrollmentModel.fromJson(enrollment))
        .toList();
  }

  // ================= FAVORITES =================

  Future<List<FavoritesModel>> getFavoriteList({
    required String userId,
    bool forceRefresh = false,
  }) async {
    final response = await learningWebService.getFavoriteList(
      userId: userId,
    );
    final List data = response['data'] ?? [];

    return data
        .map((favorite) => FavoritesModel.fromJson(favorite))
        .toList();
  }

  // ================= POPULAR =================

  Future<List<PopularModel>> getPopularList({
    bool forceRefresh = false,
  }) async {
    final response = await learningWebService.getPopularList();
    final List data = response['data'] ?? [];

    return data.map((popular) => PopularModel.fromJson(popular)).toList();
  }

  // ================= RECOMMENDED =================

  Future<List<RecommendModel>> getRecommendedList({
    bool forceRefresh = false,
  }) async {
    final response = await learningWebService.getRecommendedList();
    final List data = response['data'] ?? [];

    return data
        .map((recommended) => RecommendModel.fromJson(recommended))
        .toList();
  }

  // ================= UPDATE ENROLLMENT =================

  Future<void> updateEnrollmentProgress({
    required int enrollmentId,
    required double progressPercent,
  }) async {
    await learningWebService.updateEnrollmentProgress(
      enrollmentId: enrollmentId,
      progressPercent: progressPercent,
    );
  }

  // ================= LESSON PROGRESS =================

  Future<void> updateLessonProgress({
    required int lessonProgressId,
    required int watchedSeconds,
    required String status,
  }) async {
    final response = await _api.patch(
      '$baseUrl/items/lesson_progress/$lessonProgressId',
      body: {
        'watched_seconds': watchedSeconds,
        'status': status,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to update lesson progress: ${response.body}',
      );
    }
  }

  Future<List<LessonProgressModel>> getLessonProgressList() async {
    final response = await learningWebService.getLessonProgressList();
    final List data = response['data'] ?? [];

    return data
        .map((progress) => LessonProgressModel.fromJson(progress))
        .toList();
  }

  Future<Map<String, dynamic>> createLessonProgress({
    required int lessonId,
    required int courseId,
    required String userId,
    required int watchedSeconds,
    required String status,
  }) async {
    final response = await _api.post(
      '${apiUrl}lesson_progress',
      body: {
        'lesson': lessonId,
        'course': courseId,
        'user': userId,
        'watched_seconds': watchedSeconds,
        'status': status,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to create lesson progress: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return Map<String, dynamic>.from(decoded as Map);
  }

  Future<Map<String, dynamic>?> getUserLessonProgress({
    required int lessonId,
    required int courseId,
    required String userId,
  }) async {
    final response = await _api.get(
      '$baseUrl/items/lesson_progress'
      '?filter[lesson][_eq]=$lessonId'
      '&filter[course][_eq]=$courseId'
      '&filter[user][_eq]=$userId'
      '&limit=1',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get lesson progress: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final List data = decoded['data'] ?? [];

    if (data.isEmpty) return null;

    return Map<String, dynamic>.from(data.first as Map);
  }

  // ================= NOTIFICATIONS =================

  Future<Map<String, String>> getNotificationList({
    required String userId,
    required int enrollmentId,
  }) async {
    final response = await learningWebService.getNotificationList(
      userId: userId,
      enrollmentId: enrollmentId,
    );

    log('Fetched notifications for user $userId: $response');

    final List data = response['data'] ?? [];

    if (data.isEmpty) {
      return {
        'subject': '',
        'message': '',
      };
    }

    final first = Map<String, dynamic>.from(data.first as Map);

    return {
      'subject': first['subject']?.toString() ?? '',
      'message': first['message']?.toString() ?? '',
    };
  }
}
