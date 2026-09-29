import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:training/data/models/enrollments.dart';

/// Small persistence cache for enrollment UI state.
/// Directus remains the source of truth; server rows overwrite cached rows.
class EnrollmentCache {
  static String _key(String userId) => 'enrollments_$userId';

  static Future<List<EnrollmentModel>> read(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map>()
          .map((e) => EnrollmentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> write(String userId, List<EnrollmentModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final byCourse = <int, EnrollmentModel>{};
    for (final item in items) {
      byCourse[item.courseId] = item;
    }
    await prefs.setString(
      _key(userId),
      jsonEncode(byCourse.values.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> upsert(String userId, EnrollmentModel item) async {
    final items = await read(userId);
    final updated = [
      ...items.where((e) => e.courseId != item.courseId),
      item,
    ];
    await write(userId, updated);
  }

  static Future<void> clear(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId));
  }
}
