class LessonModel {
  late int id;
  late String title;
  late String videoUrl;
  late int duration;
  late int courseId;
late String description;
  LessonModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    videoUrl = json['video_url'];
    duration = json['duration'];
    courseId = json['course'];
    description = json['description'];
  }
}
