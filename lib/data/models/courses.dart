import 'package:training/data/api/api_constant.dart';

class CoursesModel {
  late int id;
  late String status;
  late DateTime createdAt;
  DateTime? dateUpdated;
  late String titleAr;
  late String titleEn;
  late String descriptionAr;
  late String descriptionEn;
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

    titleAr = json['title']['ar'];
    titleEn = json['title']['en'];
    descriptionAr = json['description']['ar'];
    descriptionEn = json['description']['en'];

    final thumb = json['thumbnail'].toString();
    thumbnail = thumb.startsWith('http') ? thumb : '$fileUrl$thumb';

    rating = (json['rating'] ?? 0).toDouble();
    categoryID = json['category'];
    instructorName =
        '${json['instructor']?['name'] ?? ''} ${json['instructor']?['last_name'] ?? ''}'
            .trim();
    level = json['level'];
  }
}
