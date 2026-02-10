class LessonProgressModel {
  late int id;
  late String userId; 
  late int courseId; 
  late String status;
  late int lesson; 
   LessonProgressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    courseId = json['course_id'];
    status = json['status'];
    lesson = json['lesson'] ;
  }
}