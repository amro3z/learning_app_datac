class LessonProgress {
  late int id;
  late int userId; 
  late int courseId; 
  late bool completed;
  late int lastPositionSeconds;
  late List<int> lessonIds; 
   LessonProgress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    courseId = json['course_id'];
    completed = json['completed'];
    lastPositionSeconds = json['last_position_seconds'];
    lessonIds = List<int>.from(json['lesson_ids'] ?? []);
  }
}