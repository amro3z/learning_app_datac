class FavoritesModel {
  late int id;
  late String userId;
  late int courseId;
  FavoritesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user'];
    courseId = json['course'];
  }
}
