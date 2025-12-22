class CoursesModel {
  late int id;
  late String status;
  late DateTime dateCreated;
  late DateTime dateUpdated;
  late String title;
  late String description;
  late String thumbnail;
  late double rating;
  late String totalDuration;
  late int categoryID;
  late int instructorID;
  CoursesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    dateCreated = DateTime.parse(json['date_created']);
    dateUpdated = DateTime.parse(json['date_updated']);
    title = json['title'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    rating = json['rating'];
    totalDuration = json['total_duration'];
    categoryID = json['category'];
    instructorID = json['instructor'];
  }
}
