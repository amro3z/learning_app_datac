import 'package:training/data/api/api_constant.dart';

class CoursesModel {
  late int id;
  late String status;
  late DateTime createdAt;
  DateTime? dateUpdated;
  late String title;
  late String description;
  late String thumbnail;
  late double rating;
  late int categoryID;
  late String instructorName;
  late String level;
  CoursesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    createdAt = DateTime.parse(json['date_created']);
    dateUpdated = json['date_updated'] != null
        ? DateTime.parse(json['date_updated'])
        : null;
    title = json['title'];
    description = json['description'];
    thumbnail = '$fileUrl${json['thumbnail']}';
    rating = (json['rating'] ?? 0).toDouble();
    categoryID = json['category'];
    instructorName =
        '${json['instructor']?['name'] ?? ''} ${json['instructor']?['last_name'] ?? ''}'
            .trim();
    level = json['level'];
  }
}
