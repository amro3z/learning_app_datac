import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EnrollmentStatusStore {
  static const _prefix = 'enrollment_statuses_';
  static const _allowed = {'pending', 'approved', 'rejected'};

  String _key(String userId) => '$_prefix$userId';

  Future<Map<int, String>> read(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final result = <int, String>{};
      for (final entry in decoded.entries) {
        final courseId = int.tryParse(entry.key.toString());
        final status = entry.value.toString().trim().toLowerCase();
        if (courseId != null && _allowed.contains(status)) {
          result[courseId] = status;
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<void> write(String userId, Map<int, String> statuses) async {
    final prefs = await SharedPreferences.getInstance();
    final safe = <String, String>{};
    for (final entry in statuses.entries) {
      final status = entry.value.trim().toLowerCase();
      if (_allowed.contains(status)) safe[entry.key.toString()] = status;
    }
    await prefs.setString(_key(userId), jsonEncode(safe));
  }

  Future<void> setStatus({required String userId, required int courseId, required String status}) async {
    final normalized = status.trim().toLowerCase();
    if (!_allowed.contains(normalized)) return;
    final statuses = await read(userId);
    statuses[courseId] = normalized;
    await write(userId, statuses);
  }
}
