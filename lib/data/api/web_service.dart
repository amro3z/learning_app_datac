import 'dart:convert';
import 'package:training/data/api/api_constant.dart';
import 'package:training/services/tokens/api_client.dart';

class LearningWebservice {
  final ApiClient _api = ApiClient();

  // ================= COURSES =================
  Future<Map<String, dynamic>> getCoursesList() async {
    final res = await _api.get(
      '$apiUrl/courses?fields=*,instructor.name,instructor.last_name',
    );
    return jsonDecode(res.body);
  }

  // ================= CATEGORIES =================
  Future<Map<String, dynamic>> getCategoryList() async {
    final res = await _api.get('$apiUrl/categories');
    return jsonDecode(res.body);
  }

  // ================= LESSONS =================
  Future<Map<String, dynamic>> getLessonList() async {
    final res = await _api.get('$apiUrl/lessons');
    return jsonDecode(res.body);
  }

      Future<Map<String, dynamic>> getLessonProgressList() async {
    final res = await _api.get('$apiUrl/lesson_progress');
    return jsonDecode(res.body);
  }

  // ================= INSTRUCTORS =================
  Future<Map<String, dynamic>> getInstructorList() async {
    final res = await _api.get('$apiUrl/instructors');
    return jsonDecode(res.body);
  }

  // ================= ENROLLMENTS =================
Future<Map<String, dynamic>> getEnrollmentList({
    required String userId,
  }) async {
    final res = await _api.get('$apiUrl/enrollments?filter[user][_eq]=$userId');

    return jsonDecode(res.body);
  }

  Future<void> enrollCourse({
    required int courseId,
    required String userId,
  }) async {
    await _api.post(
      '$apiUrl/enrollments',
      body: jsonEncode({"course": courseId, "user": userId}),
    );
  }

  // ================= FAVORITES =================
 Future<Map<String, dynamic>> getFavoriteList({required String userId}) async {
    final res = await _api.get('$apiUrl/favorites?filter[user][_eq]=$userId');

    return jsonDecode(res.body);
  }

  Future<void> postFavorite({
    required int courseId,
    required String userId,
  }) async {
    await _api.post(
      '$apiUrl/favorites',
      body: jsonEncode({"course": courseId, "user": userId}),
    );
  }

  Future<void> deleteFavorite({required int favoriteID}) async {
    await _api.delete('$apiUrl/favorites/$favoriteID');
  }

  // ================= RECOMMENDED =================
  Future<Map<String, dynamic>> getRecommendedList() async {
    final res = await _api.get('$apiUrl/recommended');
    return jsonDecode(res.body);
  }

  // ================= POPULAR =================
  Future<Map<String, dynamic>> getPopularList() async {
    final res = await _api.get('$apiUrl/popular');
    return jsonDecode(res.body);
  }

Future<void> updateEnrollmentProgress({
    required int enrollmentId,
    required double progressPercent,
  }) async {
    await _api.patch(
      '$apiUrl/enrollments/$enrollmentId',
      body: {"progress_percent": progressPercent},
    );
  }

Future<void> updateLessonProgress({
    required int lessonProgressId,
    required int watchedSeconds,
    required String status,
  }) async {
    await _api.patch(
      '$apiUrl/lesson_progress/$lessonProgressId',
      body: {"watched_seconds": watchedSeconds, "status": status},
    );
  }




}
