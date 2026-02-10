class LessonProgressModel {
  late int id;
  late String userId; 
  late int courseId; 
  late String status;
  late int lesson; 
   LessonProgressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user'];
    courseId = json['course'];
    status = json['status'];
    lesson = json['lesson'] ;
  }
}