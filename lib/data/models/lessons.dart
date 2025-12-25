class LessonModel {
  late int id;
  late String status;
  late int sort;
  late String title;
  late String videoUrl;
  late int duration;
  late int courseId;

  LessonModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'] ?? '';
    title = json['title'];
    videoUrl = json['video_url'];
    duration = json['duration'];
    courseId = json['course'];
  }
}
