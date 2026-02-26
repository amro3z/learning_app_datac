import 'dart:convert';
import 'dart:developer';
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

  // ================= COURSES =================

  Future<List<CoursesModel>> getCoursesList() async {
    final local = await sqldb.readData(Sql: "SELECT * FROM courses");

    if (local.isNotEmpty) {
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

    final response = await learningWebService.getCoursesList();
    final List data = response['data'] ?? [];

    final courses = data
        .map((course) => CoursesModel.fromJson(course))
        .toList();

    for (var c in courses) {
      await sqldb.insertData(
        Sql:
            '''
        INSERT OR REPLACE INTO courses (
          id, status, created_at, date_updated,
          title_ar, title_en,
          description_ar, description_en,
          thumbnail, rating, category_id,
          instructor_name, level
        ) VALUES (
          ${c.id},
          '${c.status}',
          '${c.createdAt.toIso8601String()}',
          ${c.dateUpdated != null ? "'${c.dateUpdated!.toIso8601String()}'" : "NULL"},
          '${c.titleAr}',
          '${c.titleEn}',
          '${c.descriptionAr}',
          '${c.descriptionEn}',
          '${c.thumbnail}',
          ${c.rating},
          ${c.categoryID},
          '${c.instructorName}',
          '${c.level}'
        )
      ''',
      );
    }

    return courses;
  }

  // ================= CATEGORIES =================

  Future<List<CategoriesModel>> getCategoryList() async {
    final local = await sqldb.readData(Sql: "SELECT * FROM categories");

    if (local.isNotEmpty) {
      return local.map<CategoriesModel>((e) {
        return CategoriesModel.fromJson({
          'id': e['id'],
          'title': {'ar': e['title_ar'], 'en': e['title_en']},
          'color': '#2196F3',
          'icon': e['icon'],
        });
      }).toList();
    }

    final response = await learningWebService.getCategoryList();
    final List data = response['data'] ?? [];

    final categories = data.map((c) => CategoriesModel.fromJson(c)).toList();

    for (var c in categories) {
      await sqldb.insertData(
        Sql:
            '''
        INSERT OR REPLACE INTO categories (
          id, title_ar, title_en, color, icon
        ) VALUES (
          ${c.id},
          '${c.titleAr}',
          '${c.titleEn}',
          ${c.color.value},
          '${c.icon}'
        )
      ''',
      );
    }

    return categories;
  }

  // ================= LESSONS =================

  Future<List<LessonModel>> getLessonList() async {
    final local = await sqldb.readData(Sql: "SELECT * FROM lessons");

    if (local.isNotEmpty) {
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

    final response = await learningWebService.getLessonList();
    final List data = response['data'] ?? [];

    final lessons = data.map((lesson) => LessonModel.fromJson(lesson)).toList();

    for (var l in lessons) {
      await sqldb.insertData(
        Sql:
            '''
        INSERT OR REPLACE INTO lessons (
          id, title_ar, title_en,
          description_ar, description_en,
          video_url, duration, course_id
        ) VALUES (
          ${l.id},
          '${l.titleAr}',
          '${l.titleEn}',
          '${l.descriptionAr}',
          '${l.descriptionEn}',
          '${l.videoUrl}',
          ${l.duration},
          ${l.courseId}
        )
      ''',
      );
    }

    return lessons;
  }

  // ================= INSTRUCTORS =================

  Future<List<InstructorModel>> getInstructorList() async {
    final local = await sqldb.readData(Sql: "SELECT * FROM instructors");

    if (local.isNotEmpty) {
      return local.map<InstructorModel>((e) {
        return InstructorModel.fromJson({
          'id': e['id'],
          'name': e['name'],
          'bio': e['bio'],
          'photo': e['photo'],
          'social_links': jsonDecode(e['social_links'] ?? '{}'),
        });
      }).toList();
    }

    final response = await learningWebService.getInstructorList();
    final List data = response['data'] ?? [];

    final instructors = data.map((i) => InstructorModel.fromJson(i)).toList();
    log(
      "Fetched ${instructors.length} instructors from API################################################",
    );
    for (var i in instructors) {
      await sqldb.insertData(
        Sql:
            '''
        INSERT OR REPLACE INTO instructors (
          id, name, bio, photo, social_links
        ) VALUES (
          ${i.id},
          '${i.name}',
          '${i.bio}',
          '${i.photo}',
          '${jsonEncode(i.socialLinks)}'
        )
      ''',
      );
    }

    return instructors;
  }

  // ================= ENROLLMENTS =================

  Future<List<EnrollmentModel>> getEnrollmentList({
    required String userId,
  }) async {
    final local = await sqldb.readData(
      Sql: "SELECT * FROM enrollments WHERE user_id = '$userId'",
    );

    if (local.isNotEmpty) {
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

    final response = await learningWebService.getEnrollmentList(userId: userId);

    final List list = response["data"];

    final enrollments = list.map((e) => EnrollmentModel.fromJson(e)).toList();

    for (var e in enrollments) {
      await sqldb.insertData(
        Sql:
            '''
        INSERT OR REPLACE INTO enrollments (
          id, user_id, course_id, progress_percent, date_enrolled
        ) VALUES (
          ${e.id},
          '${e.userId}',
          ${e.courseId},
          ${e.progressPercent},
          '${e.dateEnrolled.toIso8601String()}'
        )
      ''',
      );
    }

    return enrollments;
  }

  // ================= FAVORITES =================

  Future<List<FavoritesModel>> getFavoriteList({required String userId}) async {
    final local = await sqldb.readData(
      Sql: "SELECT * FROM favorites WHERE user_id = '$userId'",
    );

    if (local.isNotEmpty) {
      return local.map<FavoritesModel>((e) {
        return FavoritesModel.fromJson({
          'id': e['id'],
          'user': e['user_id'],
          'course': e['course_id'],
        });
      }).toList();
    }

    final response = await learningWebService.getFavoriteList(userId: userId);

    final List list = response["data"];

    final favorites = list.map((e) => FavoritesModel.fromJson(e)).toList();

    for (var f in favorites) {
      await sqldb.insertData(
        Sql:
            '''
        INSERT OR REPLACE INTO favorites (
          id, user_id, course_id
        ) VALUES (
          ${f.id},
          '${f.userId}',
          ${f.courseId}
        )
      ''',
      );
    }

    return favorites;
  }

  // ================= POPULAR =================

  Future<List<PopularModel>> getPopularList() async {
    final local = await sqldb.readData(Sql: "SELECT * FROM popular");

    if (local.isNotEmpty) {
      return local.map<PopularModel>((e) {
        return PopularModel.fromJson({
          'id': e['id'],
          'course': e['course_id'],
          'user': e['user_id'],
        });
      }).toList();
    }

    final response = await learningWebService.getPopularList();
    final List data = response['data'] ?? [];

    final popular = data.map((p) => PopularModel.fromJson(p)).toList();

    for (var p in popular) {
      await sqldb.insertData(
        Sql:
            '''
        INSERT OR REPLACE INTO popular (
          id, course_id, user_id
        ) VALUES (
          ${p.id},
          ${p.course},
          '${p.user}'
        )
      ''',
      );
    }

    return popular;
  }

  // ================= RECOMMEND =================

  Future<List<RecommendModel>> getRecommendedList() async {
    final local = await sqldb.readData(Sql: "SELECT * FROM recommend");

    if (local.isNotEmpty) {
      return local.map<RecommendModel>((e) {
        return RecommendModel.fromJson({
          'id': e['id'],
          'user': e['user_id'],
          'recommend_course': e['recommend_course_id'],
        });
      }).toList();
    }

    final response = await learningWebService.getRecommendedList();
    final List data = response['data'] ?? [];

    final recommend = data.map((r) => RecommendModel.fromJson(r)).toList();

    for (var r in recommend) {
      await sqldb.insertData(
        Sql:
            '''
        INSERT OR REPLACE INTO recommend (
          id, user_id, recommend_course_id
        ) VALUES (
          ${r.id},
          '${r.user}',
          ${r.recommendCourse}
        )
      ''',
      );
    }

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
      Sql:
          '''
      UPDATE enrollments
      SET progress_percent = $progressPercent
      WHERE id = $enrollmentId
    ''',
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
      Sql:
          '''
      UPDATE lesson_progress
      SET watched_seconds = $watchedSeconds,
          status = '$status'
      WHERE id = $lessonProgressId
    ''',
    );
  }

  // ================= Lesson Progress =================

  Future<List<LessonProgressModel>> getLessonProgressList() async {
    final response = await learningWebService.getLessonProgressList();
    final List data = response['data'] ?? [];

    final progress = data.map((p) => LessonProgressModel.fromJson(p)).toList();

    // 🔥 تخزين في SQLite
    for (var p in progress) {
      await sqldb.insertData(
        Sql:
            '''
        INSERT OR REPLACE INTO lesson_progress (
          id,
          user_id,
          course_id,
          status,
          lesson_id,
          watched_seconds
        ) VALUES (
          ${p.id},
          '${p.userId}',
          ${p.courseId},
          '${p.status}',
          ${p.lesson},
          ${p.watchedSeconds}
        )
      ''',
      );
    }

    return progress;
  }
}
