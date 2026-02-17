class LessonProgressModel {
  late int id;
  late String userId; 
  late int courseId; 
  late String status;
  late int lesson; 
  late int watchedSeconds;
   LessonProgressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user'];
    courseId = json['course'];
    status = json['status'];
    lesson = json['lesson'] ;
    watchedSeconds = json['watched_seconds'] ?? 0;
  }

  LessonProgressModel.empty() {
    id = 0;
    userId = "";
    courseId = 0;
    status = "";
    lesson = 0;
    watchedSeconds = 0;
  }

}

