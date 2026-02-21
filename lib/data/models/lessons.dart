class LessonModel {
  late int id;
  late String titleAr;
  late String titleEn;
  late String videoUrl;
  late int duration;
  late int courseId;
  late String descriptionAr;
  late String descriptionEn;
  LessonModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titleAr = json['title']['ar'];
    titleEn = json['title']['en'];
    descriptionAr = json['description']['ar'];
    descriptionEn = json['description']['en'];
    videoUrl = json['video_url'];
    duration = json['duration'];
    courseId = json['course'];
  }
}
