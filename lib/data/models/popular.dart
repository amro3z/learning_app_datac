class PopularModel {
  late final int id;
  late final int course;
  late final String user;
  PopularModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    course = json['course'];
    user = json['user'];
  }
}
