import 'dart:convert';
import 'package:training/data/api/api_constant.dart';
import 'package:training/utils/services/tokens/api_client.dart';

class LearningWebservice {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> getCoursesList() async {
    final res = await _api.get(
      '$apiUrl/courses?fields=*,instructor.name,instructor.last_name',
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getCategoryList() async {
    final res = await _api.get('$apiUrl/categories');
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getLessonList() async {
    final res = await _api.get('$apiUrl/lessons');
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getLessonProgressList() async {
    final res = await _api.get('$apiUrl/lesson_progress');
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getInstructorList() async {
    final res = await _api.get('$apiUrl/instructors');
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getEnrollmentList({
    required String userId,
    bool forceRefresh = false,
  }) async {

    final uri = Uri.parse('$apiUrl/enrollments').replace(queryParameters: {
      'fields': 'id,user,course,status,date_enrolled,completed_lessons.lessons_id',
      'filter[user][_eq]': userId,
      'sort': '-id',
      'limit': '-1',
      '_ts': DateTime.now().microsecondsSinceEpoch.toString(),
    });

    final res = await _api.get(uri.toString(), noCache: true);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'Failed to load enrollments (${res.statusCode}): ${res.body}',
      );
    }

    final decoded = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    final rows = (decoded['data'] as List?) ?? const [];

    String relationId(dynamic value) {
      if (value is Map) return (value['id'] ?? '').toString();
      return (value ?? '').toString();
    }

    decoded['data'] = rows
        .where((row) => row is Map && relationId(row['user']) == userId)
        .toList();
    return decoded;
  }

  Future<Map<String, dynamic>?> getEnrollmentForCourse({
    required int courseId,
    required String userId,
  }) async {

    final decoded = await getEnrollmentList(
      userId: userId,
      forceRefresh: true,
    );
    final rows = (decoded['data'] as List?) ?? const [];

    int relationInt(dynamic value) {
      if (value is Map) value = value['id'];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse((value ?? '').toString()) ?? 0;
    }

    for (final row in rows) {
      if (row is Map && relationInt(row['course']) == courseId) {
        return Map<String, dynamic>.from(row);
      }
    }
    return null;
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

  Future<Map<String, dynamic>> getRecommendedList() async {
    final res = await _api.get('$apiUrl/recommended');
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getPopularList() async {
    final res = await _api.get('$apiUrl/popular');
    return jsonDecode(res.body);
  }

 Future<void> addCompletedLesson({
    required int enrollmentId,
    required int lessonId,
  }) async {
    final checkUri = Uri.parse('${apiUrl}enrollments_lessons').replace(
      queryParameters: {
        'fields': 'id,enrollments_id,lessons_id',
        'filter[enrollments_id][_eq]': enrollmentId.toString(),
        'filter[lessons_id][_eq]': lessonId.toString(),
        'limit': '1',
        '_ts': DateTime.now().microsecondsSinceEpoch.toString(),
      },
    );

    final checkResponse = await _api.get(checkUri.toString(), noCache: true);
    print('[COMPLETED_LESSON_API] CHECK | enrollment=$enrollmentId | lesson=$lessonId | status=${checkResponse.statusCode} | body=${checkResponse.body}');

    if (checkResponse.statusCode >= 200 && checkResponse.statusCode < 300) {
      final decoded = jsonDecode(checkResponse.body);
      final data = decoded is Map ? decoded['data'] : null;
      if (data is List && data.isNotEmpty) {
        print('[COMPLETED_LESSON_API] SKIP | enrollment=$enrollmentId | lesson=$lessonId | reason=junction_exists');
        return;
      }
    }

    final body = jsonEncode({
      'enrollments_id': enrollmentId,
      'lessons_id': lessonId,
    });
    print('[COMPLETED_LESSON_API] POST | enrollment=$enrollmentId | lesson=$lessonId | body=$body');

    final response = await _api.post(
      '${apiUrl}enrollments_lessons',
      body: body,
    );
    print('[COMPLETED_LESSON_API] RESPONSE | enrollment=$enrollmentId | lesson=$lessonId | status=${response.statusCode} | body=${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to create completed lesson relation (${response.statusCode}): ${response.body}',
      );
    }
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
