class Favorites {
  late int id;
  late String userId;
  late int courseId;
  Favorites.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user'];
    courseId = json['course'];
  }
}
