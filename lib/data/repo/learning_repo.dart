// lib/data/repo/learning_repo.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:training/data/api/web_service.dart';
import 'package:training/data/local/sqldb.dart';
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
  final Sqldb sqldb;

  LearningRepo({required this.learningWebService, required this.sqldb});

  // TTL لكل جدول (غيرهم زي ما تحب)
  static const Duration _ttlCourses = Duration(hours: 6);
  static const Duration _ttlCategories = Duration(days: 2);
  static const Duration _ttlLessons = Duration(hours: 12);
  static const Duration _ttlInstructors = Duration(days: 2);
  static const Duration _ttlPopular = Duration(hours: 6);
  static const Duration _ttlRecommend = Duration(hours: 6);

  String _syncKey(String table) => 'last_sync_$table';

  Future<bool> _shouldRefresh(String table, Duration ttl) async {
    final last = await sqldb.getMeta(_syncKey(table));
    if (last == null) return true;

    final lastDt = DateTime.tryParse(last);
    if (lastDt == null) return true;

    return DateTime.now().difference(lastDt) > ttl;
  }

  Future<void> _markSynced(String table) async {
    await sqldb.setMeta(_syncKey(table), DateTime.now().toIso8601String());
  }

  // ==================== LOCAL MAPPERS ====================

  List<CoursesModel> _mapLocalCourses(List<Map<String, Object?>> local) {
    return local.map<CoursesModel>((e) {
      return CoursesModel.fromJson({
        'id': e['id'],
        'status': e['status'],
        'date_created': e['created_at'],
        'date_updated': e['date_updated'],
        'title': {'ar': e['title_ar'], 'en': e['title_en']},
        'description': {'ar': e['description_ar'], 'en': e['description_en']},
        'thumbnail': e['thumbnail'],
        'rating': e['rating'],
        'category': e['category_id'],
        'instructor': {'name': e['instructor_name'], 'last_name': ''},
        'level': e['level'],
      });
    }).toList();
  }

  List<CategoriesModel> _mapLocalCategories(List<Map<String, Object?>> local) {
    return local.map<CategoriesModel>((e) {
      final colorInt = (e['color'] as int?) ?? 0xFF2196F3;
      final hex =
          '#${(colorInt & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
      return CategoriesModel.fromJson({
        'id': e['id'],
        'title': {'ar': e['title_ar'], 'en': e['title_en']},
        'color': hex,
        'icon': e['icon'],
      });
    }).toList();
  }

  List<LessonModel> _mapLocalLessons(List<Map<String, Object?>> local) {
    return local.map<LessonModel>((e) {
      return LessonModel.fromJson({
        'id': e['id'],
        'title': {'ar': e['title_ar'], 'en': e['title_en']},
        'description': {'ar': e['description_ar'], 'en': e['description_en']},
        'video_url': e['video_url'],
        'duration': e['duration'],
        'course': e['course_id'],
      });
    }).toList();
  }

  List<InstructorModel> _mapLocalInstructors(List<Map<String, Object?>> local) {
    return local.map<InstructorModel>((e) {
      return InstructorModel.fromJson({
        'id': e['id'],
        'name': e['name'],
        'bio': e['bio'],
        'photo': e['photo'],
        'social_links': jsonDecode((e['social_links'] as String?) ?? '{}'),
      });
    }).toList();
  }

  List<EnrollmentModel> _mapLocalEnrollments(List<Map<String, Object?>> local) {
    return local.map<EnrollmentModel>((e) {
      return EnrollmentModel.fromJson({
        'id': e['id'],
        'user': e['user_id'],
        'course': e['course_id'],
        'progress_percent': e['progress_percent'],
        'date_enrolled': e['date_enrolled'],
      });
    }).toList();
  }

  List<FavoritesModel> _mapLocalFavorites(List<Map<String, Object?>> local) {
    return local.map<FavoritesModel>((e) {
      return FavoritesModel.fromJson({
        'id': e['id'],
        'user': e['user_id'],
        'course': e['course_id'],
      });
    }).toList();
  }

  List<PopularModel> _mapLocalPopular(List<Map<String, Object?>> local) {
    return local.map<PopularModel>((e) {
      return PopularModel.fromJson({
        'id': e['id'],
        'course': e['course_id'],
        'user': e['user_id'],
      });
    }).toList();
  }

  List<RecommendModel> _mapLocalRecommend(List<Map<String, Object?>> local) {
    return local.map<RecommendModel>((e) {
      return RecommendModel.fromJson({
        'id': e['id'],
        'user': e['user_id'],
        'recommend_course': e['recommend_course_id'],
      });
    }).toList();
  }

  // ================= COURSES =================

  Future<List<CoursesModel>> getCoursesList({bool forceRefresh = false}) async {
    final local = await sqldb.readData(sql: "SELECT * FROM courses");
    if (local.isNotEmpty) {
      final mapped = _mapLocalCourses(local);

      final needRefresh =
          forceRefresh || await _shouldRefresh('courses', _ttlCourses);

      if (needRefresh) {
        unawaited(_refreshCoursesSafely());
      }
      return mapped;
    }

    return _refreshCoursesSafely();
  }

  Future<List<CoursesModel>> _refreshCoursesSafely() async {
    try {
      return await _refreshCourses();
    } on SocketException {
      final local = await sqldb.readData(sql: "SELECT * FROM courses");
      return _mapLocalCourses(local);
    } catch (e) {
      final local = await sqldb.readData(sql: "SELECT * FROM courses");
      if (local.isNotEmpty) return _mapLocalCourses(local);
      rethrow;
    }
  }

  Future<List<CoursesModel>> _refreshCourses() async {
    final response = await learningWebService.getCoursesList();
    final List data = response['data'] ?? [];

    final courses = data
        .map((course) => CoursesModel.fromJson(course))
        .toList();

    await sqldb.runBatch((b) async {
      for (var c in courses) {
        b.rawInsert(
          '''
          INSERT OR REPLACE INTO courses (
            id, status, created_at, date_updated,
            title_ar, title_en,
            description_ar, description_en,
            thumbnail, rating, category_id,
            instructor_name, level
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            c.id,
            c.status,
            c.createdAt.toIso8601String(),
            c.dateUpdated?.toIso8601String(),
            c.titleAr,
            c.titleEn,
            c.descriptionAr,
            c.descriptionEn,
            c.thumbnail,
            c.rating,
            c.categoryID,
            c.instructorName,
            c.level,
          ],
        );
      }
    });

    await _markSynced('courses');
    return courses;
  }

  // ================= CATEGORIES =================

  Future<List<CategoriesModel>> getCategoryList({
    bool forceRefresh = false,
  }) async {
    final local = await sqldb.readData(sql: "SELECT * FROM categories");
    if (local.isNotEmpty) {
      final mapped = _mapLocalCategories(local);

      final needRefresh =
          forceRefresh || await _shouldRefresh('categories', _ttlCategories);
      if (needRefresh) unawaited(_refreshCategoriesSafely());

      return mapped;
    }

    return _refreshCategoriesSafely();
  }

  Future<List<CategoriesModel>> _refreshCategoriesSafely() async {
    try {
      return await _refreshCategories();
    } on SocketException {
      final local = await sqldb.readData(sql: "SELECT * FROM categories");
      return _mapLocalCategories(local);
    } catch (e) {
      final local = await sqldb.readData(sql: "SELECT * FROM categories");
      if (local.isNotEmpty) return _mapLocalCategories(local);
      rethrow;
    }
  }

  Future<List<CategoriesModel>> _refreshCategories() async {
    final response = await learningWebService.getCategoryList();
    final List data = response['data'] ?? [];

    final categories = data.map((c) => CategoriesModel.fromJson(c)).toList();

    await sqldb.runBatch((b) async {
      for (var c in categories) {
        b.rawInsert(
          '''
          INSERT OR REPLACE INTO categories (
            id, title_ar, title_en, color, icon
          ) VALUES (?, ?, ?, ?, ?)
          ''',
          [c.id, c.titleAr, c.titleEn, c.color.value, c.icon],
        );
      }
    });

    await _markSynced('categories');
    return categories;
  }

  // ================= LESSONS =================

  Future<List<LessonModel>> getLessonList({bool forceRefresh = false}) async {
    final local = await sqldb.readData(sql: "SELECT * FROM lessons");
    if (local.isNotEmpty) {
      final mapped = _mapLocalLessons(local);

      final needRefresh =
          forceRefresh || await _shouldRefresh('lessons', _ttlLessons);
      if (needRefresh) unawaited(_refreshLessonsSafely());

      return mapped;
    }

    return _refreshLessonsSafely();
  }

  Future<List<LessonModel>> _refreshLessonsSafely() async {
    try {
      return await _refreshLessons();
    } on SocketException {
      final local = await sqldb.readData(sql: "SELECT * FROM lessons");
      return _mapLocalLessons(local);
    } catch (e) {
      final local = await sqldb.readData(sql: "SELECT * FROM lessons");
      if (local.isNotEmpty) return _mapLocalLessons(local);
      rethrow;
    }
  }

  Future<List<LessonModel>> _refreshLessons() async {
    final response = await learningWebService.getLessonList();
    final List data = response['data'] ?? [];

    final lessons = data.map((lesson) => LessonModel.fromJson(lesson)).toList();

    await sqldb.runBatch((b) async {
      for (var l in lessons) {
        b.rawInsert(
          '''
          INSERT OR REPLACE INTO lessons (
            id, title_ar, title_en,
            description_ar, description_en,
            video_url, duration, course_id
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            l.id,
            l.titleAr,
            l.titleEn,
            l.descriptionAr,
            l.descriptionEn,
            l.videoUrl,
            l.duration,
            l.courseId,
          ],
        );
      }
    });

    await _markSynced('lessons');
    return lessons;
  }

  // ================= INSTRUCTORS =================

  Future<List<InstructorModel>> getInstructorList({
    bool forceRefresh = false,
  }) async {
    final local = await sqldb.readData(sql: "SELECT * FROM instructors");
    if (local.isNotEmpty) {
      final mapped = _mapLocalInstructors(local);

      final needRefresh =
          forceRefresh || await _shouldRefresh('instructors', _ttlInstructors);
      if (needRefresh) unawaited(_refreshInstructorsSafely());

      return mapped;
    }

    return _refreshInstructorsSafely();
  }

  Future<List<InstructorModel>> _refreshInstructorsSafely() async {
    try {
      return await _refreshInstructors();
    } on SocketException {
      final local = await sqldb.readData(sql: "SELECT * FROM instructors");
      return _mapLocalInstructors(local);
    } catch (e) {
      final local = await sqldb.readData(sql: "SELECT * FROM instructors");
      if (local.isNotEmpty) return _mapLocalInstructors(local);
      rethrow;
    }
  }

  Future<List<InstructorModel>> _refreshInstructors() async {
    final response = await learningWebService.getInstructorList();
    final List data = response['data'] ?? [];

    final instructors = data.map((i) => InstructorModel.fromJson(i)).toList();
    log("Fetched ${instructors.length} instructors from API");

    await sqldb.runBatch((b) async {
      for (var i in instructors) {
        b.rawInsert(
          '''
          INSERT OR REPLACE INTO instructors (
            id, name, bio, photo, social_links
          ) VALUES (?, ?, ?, ?, ?)
          ''',
          [i.id, i.name, i.bio, i.photo, jsonEncode(i.socialLinks)],
        );
      }
    });

    await _markSynced('instructors');
    return instructors;
  }

  // ================= ENROLLMENTS (per user) =================

  Future<List<EnrollmentModel>> getEnrollmentList({
    required String userId,
    bool forceRefresh = false,
  }) async {
    final local = await sqldb.readData(
      sql: "SELECT * FROM enrollments WHERE user_id = ?",
      args: [userId],
    );

    if (local.isNotEmpty && !forceRefresh) {
      return _mapLocalEnrollments(local);
    }

    try {
      final response = await learningWebService.getEnrollmentList(
        userId: userId,
      );
      final List list = response["data"] ?? [];

      final enrollments = list.map((e) => EnrollmentModel.fromJson(e)).toList();

      await sqldb.runBatch((b) async {
        for (var e in enrollments) {
          b.rawInsert(
            '''
            INSERT OR REPLACE INTO enrollments (
              id, user_id, course_id, progress_percent, date_enrolled
            ) VALUES (?, ?, ?, ?, ?)
            ''',
            [
              e.id,
              e.userId,
              e.courseId,
              e.progressPercent,
              e.dateEnrolled.toIso8601String(),
            ],
          );
        }
      });

      return enrollments;
    } on SocketException {
      return _mapLocalEnrollments(local);
    } catch (e) {
      if (local.isNotEmpty) return _mapLocalEnrollments(local);
      rethrow;
    }
  }

  // ================= FAVORITES (per user) =================

  Future<List<FavoritesModel>> getFavoriteList({
    required String userId,
    bool forceRefresh = false,
  }) async {
    final local = await sqldb.readData(
      sql: "SELECT * FROM favorites WHERE user_id = ?",
      args: [userId],
    );

    if (local.isNotEmpty && !forceRefresh) {
      return _mapLocalFavorites(local);
    }

    try {
      final response = await learningWebService.getFavoriteList(userId: userId);
      final List list = response["data"] ?? [];

      final favorites = list.map((e) => FavoritesModel.fromJson(e)).toList();

      await sqldb.runBatch((b) async {
        for (var f in favorites) {
          b.rawInsert(
            '''
            INSERT OR REPLACE INTO favorites (
              id, user_id, course_id
            ) VALUES (?, ?, ?)
            ''',
            [f.id, f.userId, f.courseId],
          );
        }
      });

      return favorites;
    } on SocketException {
      return _mapLocalFavorites(local);
    } catch (e) {
      if (local.isNotEmpty) return _mapLocalFavorites(local);
      rethrow;
    }
  }

  // ================= POPULAR =================

  Future<List<PopularModel>> getPopularList({bool forceRefresh = false}) async {
    final local = await sqldb.readData(sql: "SELECT * FROM popular");

    if (local.isNotEmpty) {
      final mapped = _mapLocalPopular(local);

      final needRefresh =
          forceRefresh || await _shouldRefresh('popular', _ttlPopular);
      if (needRefresh) unawaited(_refreshPopularSafely());

      return mapped;
    }

    return _refreshPopularSafely();
  }

  Future<List<PopularModel>> _refreshPopularSafely() async {
    try {
      return await _refreshPopular();
    } on SocketException {
      final local = await sqldb.readData(sql: "SELECT * FROM popular");
      return _mapLocalPopular(local);
    } catch (e) {
      final local = await sqldb.readData(sql: "SELECT * FROM popular");
      if (local.isNotEmpty) return _mapLocalPopular(local);
      rethrow;
    }
  }

  Future<List<PopularModel>> _refreshPopular() async {
    final response = await learningWebService.getPopularList();
    final List data = response['data'] ?? [];

    final popular = data.map((p) => PopularModel.fromJson(p)).toList();

    await sqldb.runBatch((b) async {
      for (var p in popular) {
        b.rawInsert(
          '''
          INSERT OR REPLACE INTO popular (
            id, course_id, user_id
          ) VALUES (?, ?, ?)
          ''',
          [p.id, p.course, p.user],
        );
      }
    });

    await _markSynced('popular');
    return popular;
  }

  // ================= RECOMMEND =================

  Future<List<RecommendModel>> getRecommendedList({
    bool forceRefresh = false,
  }) async {
    final local = await sqldb.readData(sql: "SELECT * FROM recommend");

    if (local.isNotEmpty) {
      final mapped = _mapLocalRecommend(local);

      final needRefresh =
          forceRefresh || await _shouldRefresh('recommend', _ttlRecommend);
      if (needRefresh) unawaited(_refreshRecommendSafely());

      return mapped;
    }

    return _refreshRecommendSafely();
  }

  Future<List<RecommendModel>> _refreshRecommendSafely() async {
    try {
      return await _refreshRecommend();
    } on SocketException {
      final local = await sqldb.readData(sql: "SELECT * FROM recommend");
      return _mapLocalRecommend(local);
    } catch (e) {
      final local = await sqldb.readData(sql: "SELECT * FROM recommend");
      if (local.isNotEmpty) return _mapLocalRecommend(local);
      rethrow;
    }
  }

  Future<List<RecommendModel>> _refreshRecommend() async {
    final response = await learningWebService.getRecommendedList();
    final List data = response['data'] ?? [];

    final recommend = data.map((r) => RecommendModel.fromJson(r)).toList();

    await sqldb.runBatch((b) async {
      for (var r in recommend) {
        b.rawInsert(
          '''
          INSERT OR REPLACE INTO recommend (
            id, user_id, recommend_course_id
          ) VALUES (?, ?, ?)
          ''',
          [r.id, r.user, r.recommendCourse],
        );
      }
    });

    await _markSynced('recommend');
    return recommend;
  }

  // ================= UPDATE =================

  Future<void> updateEnrollmentProgress({
    required int enrollmentId,
    required double progressPercent,
  }) async {
    await learningWebService.updateEnrollmentProgress(
      enrollmentId: enrollmentId,
      progressPercent: progressPercent,
    );

    await sqldb.updateData(
      sql: '''
        UPDATE enrollments
        SET progress_percent = ?
        WHERE id = ?
      ''',
      args: [progressPercent, enrollmentId],
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

    await sqldb.updateData(
      sql: '''
        UPDATE lesson_progress
        SET watched_seconds = ?,
            status = ?
        WHERE id = ?
      ''',
      args: [watchedSeconds, status, lessonProgressId],
    );
  }

  // ================= Lesson Progress =================

  Future<List<LessonProgressModel>> getLessonProgressList() async {
    final local = await sqldb.readData(sql: "SELECT * FROM lesson_progress");

    try {
      final response = await learningWebService.getLessonProgressList();
      final List data = response['data'] ?? [];

      final progress = data
          .map((p) => LessonProgressModel.fromJson(p))
          .toList();

      await sqldb.runBatch((b) async {
        for (var p in progress) {
          b.rawInsert(
            '''
            INSERT OR REPLACE INTO lesson_progress (
              id, user_id, course_id, status, lesson_id, watched_seconds
            ) VALUES (?, ?, ?, ?, ?, ?)
            ''',
            [p.id, p.userId, p.courseId, p.status, p.lesson, p.watchedSeconds],
          );
        }
      });

      return progress;
    } on SocketException {
      return local.map<LessonProgressModel>((e) {
        return LessonProgressModel.fromJson({
          'id': e['id'],
          'user': e['user_id'],
          'course': e['course_id'],
          'status': e['status'],
          'lesson': e['lesson_id'],
          'watched_seconds': e['watched_seconds'],
        });
      }).toList();
    } catch (e) {
      if (local.isNotEmpty) {
        return local.map<LessonProgressModel>((e) {
          return LessonProgressModel.fromJson({
            'id': e['id'],
            'user': e['user_id'],
            'course': e['course_id'],
            'status': e['status'],
            'lesson': e['lesson_id'],
            'watched_seconds': e['watched_seconds'],
          });
        }).toList();
      }
      rethrow;
    }
  }
}
