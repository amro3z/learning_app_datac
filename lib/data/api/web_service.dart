import 'dart:convert';
import 'package:training/data/api/api_constant.dart';
import 'package:training/utils/services/tokens/api_client.dart';

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
    bool forceRefresh = false,
  }) async {
    // A cache-buster is important here because enrollment status is changed from
    // Directus (pending -> approved/rejected) outside the Flutter application.
    // Without it, a proxy/browser cache can keep returning the old response.
    final cacheBuster = '&_=${DateTime.now().millisecondsSinceEpoch}';
    final res = await _api.get(
      '$apiUrl/enrollments?filter[user][_eq]=$userId'
      '&fields=id,user,course,status,date_enrolled,completed_lessons.lessons_id'
      '$cacheBuster',
      noCache: true,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to load enrollments (${res.statusCode}): ${res.body}');
    }
    return jsonDecode(res.body);
  }


  Future<Map<String, dynamic>?> getEnrollmentForCourse({
    required int courseId,
    required String userId,
  }) async {
    final cacheBuster = '&_=${DateTime.now().millisecondsSinceEpoch}';
    final res = await _api.get(
      '$apiUrl/enrollments?filter[user][_eq]=$userId'
      '&filter[course][_eq]=$courseId'
      '&fields=id,user,course,status,date_enrolled,completed_lessons.lessons_id'
      '&sort=-id&limit=1$cacheBuster',
      noCache: true,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to check enrollment (${res.statusCode}): ${res.body}');
    }
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (decoded['data'] as List?) ?? const [];
    if (data.isEmpty) return null;
    return Map<String, dynamic>.from(data.first as Map);
  }

  Future<Map<String, dynamic>> enrollCourse({
    required int courseId,
    required String userId,
  }) async {
    final response = await _api.post(
      '$apiUrl/enrollments',
      body: jsonEncode({
        "course": courseId,
        "user": userId,
        "status": "pending",
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to request enrollment (${response.statusCode}): ${response.body}');
    }
    return jsonDecode(response.body);
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
      body: jsonEncode({
        "course": courseId,
        "user": userId,
        "status": "pending",
      }),
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

  // ================= Enrollment =================

 Future<void> addCompletedLesson({
    required int enrollmentId,
    required List<int> completedLessonIds,
  }) async {
    await _api.patch(
      '${apiUrl}enrollments/$enrollmentId',
      body: jsonEncode({"completed_lessons": completedLessonIds}),
    );
  }

  // ================= Lesson Progress  =================

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

  // ================= Notification =================

  Future<Map<String, dynamic>> getNotificationList({
    required String userId,
    required int enrollmentId,
  }) async {
    final res = await _api.get(
      '$baseUrl/notifications?filter[recipient][_eq]=$userId&filter[item][_eq]=$enrollmentId',
    );
    return jsonDecode(res.body);
  }

}
