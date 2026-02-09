import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:training/data/api/api_constant.dart';
import 'package:training/services/tokens/auths_service.dart';

class LearningWebservice {
  late final Dio dio;
  final AuthService _auth = AuthService();

  LearningWebservice() {
    final options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );

    dio = Dio(options);

    /// ===== Interceptor (TOKEN + REFRESH) =====
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _auth.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        onError: (DioException e, handler) async {
          final isUnauthorized =
              e.response?.statusCode == 401 ||
              e.response?.data?['errors']?[0]?['extensions']?['code'] ==
                  'TOKEN_EXPIRED';

          if (isUnauthorized) {
            final refreshed = await _auth.refreshTokenIfNeeded();

            if (refreshed) {
              final newToken = _auth.token;
              final req = e.requestOptions;

              req.headers['Authorization'] = 'Bearer $newToken';

              try {
                final retryResponse = await dio.fetch(req);
                return handler.resolve(retryResponse);
              } catch (err) {
                return handler.reject(err as DioException);
              }
            }
          }

          return handler.reject(e);
        },
      ),
    );
  }

  // ================= COURSES =================
  Future<Map<String, dynamic>> getCoursesList() async {
    try {
      final response = await dio.get(
        '$apiUrl/courses',
        queryParameters: {'fields': '*,instructor.name,instructor.last_name'},
      );
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ================= CATEGORIES =================
  Future<Map<String, dynamic>> getCategoryList() async {
    try {
      final response = await dio.get('$apiUrl/categories');
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ================= LESSONS =================
  Future<Map<String, dynamic>> getLessonList() async {
    try {
      final response = await dio.get('$apiUrl/lessons');
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ================= INSTRUCTORS =================
  Future<Map<String, dynamic>> getInstructorList() async {
    try {
      final response = await dio.get('$apiUrl/instructors');
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ================= LESSON PROGRESS =================
  Future<Map<String, dynamic>> getLessonProgressList() async {
    try {
      final response = await dio.get('$apiUrl/lesson_progress');
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ================= ENROLLMENTS =================
  Future<Map<String, dynamic>> getEnrollmentList() async {
    try {
      final response = await dio.get('$apiUrl/enrollments');
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ================= FAVORITES =================
  Future<Map<String, dynamic>> getFavoriteList() async {
    try {
      final response = await dio.get('$apiUrl/favorites');
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
  
    Future<Map<String, dynamic>> getRecommendedList() async {
    try {
      final response = await dio.get('$apiUrl/recommended');
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

      Future<Map<String, dynamic>> getPopularList() async {
    try {
      final response = await dio.get('$apiUrl/popular');
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}



