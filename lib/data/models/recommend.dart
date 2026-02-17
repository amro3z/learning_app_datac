class RecommendModel {
 late final int id;
  late final String user;
  late  final int recommendCourse;

  RecommendModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'];
    recommendCourse = json['recommend_course'];
  }
}
