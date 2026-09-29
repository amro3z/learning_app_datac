class EnrollmentModel {
  final int id;
  final String userId;
  final int courseId;
  final String status;
  final DateTime? requestedAt;
  final DateTime? dateEnrolled;
  final List<int> completedLessonIds;

  const EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.status,
    this.requestedAt,
    this.dateEnrolled,
    this.completedLessonIds = const [],
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  double progressFor(int totalLessons) {
    if (totalLessons <= 0) return 0;
    return (completedLessonIds.length / totalLessons).clamp(0.0, 1.0);
  }

  EnrollmentModel copyWith({String? status, List<int>? completedLessonIds}) {
    return EnrollmentModel(
      id: id,
      userId: userId,
      courseId: courseId,
      status: status ?? this.status,
      requestedAt: requestedAt,
      dateEnrolled: dateEnrolled,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': userId,
    'course': courseId,
    'status': status,
    if (requestedAt != null) 'requested_at': requestedAt!.toIso8601String(),
    if (dateEnrolled != null) 'date_enrolled': dateEnrolled!.toIso8601String(),
    'completed_lessons': completedLessonIds,
  };

  static int _intId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is Map) return _intId(value['id']);
    return 0;
  }

  static String _stringId(dynamic value) {
    if (value is Map) return (value['id'] ?? '').toString();
    return (value ?? '').toString();
  }

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    final raw = (json['completed_lessons'] as List?) ?? const [];
    final ids = raw.map<int?>((item) {
      final value = item is Map
          ? (item['lessons_id'] ?? item['lesson_id'] ?? item['id'])
          : item;
      final id = _intId(value);
      return id == 0 ? null : id;
    }).whereType<int>().toSet().toList();

    return EnrollmentModel(
      id: _intId(json['id']),
      userId: _stringId(json['user']),
      courseId: _intId(json['course']),
      status: (json['status'] ?? 'pending').toString().trim().toLowerCase(),
      requestedAt: DateTime.tryParse((json['requested_at'] ?? '').toString()),
      dateEnrolled: DateTime.tryParse((json['date_enrolled'] ?? '').toString()),
      completedLessonIds: ids,
    );
  }
}
