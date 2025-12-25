import 'package:training/data/api/api_constant.dart';

class CoursesModel {
  late int id;
  late String status;
  late DateTime dateCreated;
  DateTime? dateUpdated;
  late String title;
  late String description;
  late String thumbnail;
  late double rating;
  late int totalDuration;
  late int categoryID;
  late String instructorName;
  late int progress;

  CoursesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    dateCreated = DateTime.parse(json['date_created']);
    dateUpdated = json['date_updated'] != null
        ? DateTime.parse(json['date_updated'])
        : null;
    title = json['title'];
    description = json['description'];
    thumbnail =
        '$fileUrl${json['thumbnail']}';
    rating = (json['rating'] ?? 0).toDouble();
    totalDuration = json['total_duration'];
    categoryID = json['category'];
instructorName =
        '${json['instructor']?['name'] ?? ''} ${json['instructor']?['last_name'] ?? ''}'.trim();
    progress = json['progress'] ?? 0;
  }
}
