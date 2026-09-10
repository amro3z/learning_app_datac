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

    status = json['status']?.toString() ?? '';

    createdAt = DateTime.parse(json['date_created'].toString());

    dateUpdated = json['date_updated'] != null
        ? DateTime.parse(json['date_updated'].toString())
        : null;

    final title = json['title'];

    if (title is Map) {
      titleAr = title['ar']?.toString() ?? '';
      titleEn = title['en']?.toString() ?? '';
    } else {
      titleAr = '';
      titleEn = '';
    }

    final description = json['description'];

    if (description is Map) {
      descriptionAr = description['ar']?.toString() ?? '';

      descriptionEn = description['en']?.toString() ?? '';
    } else {
      descriptionAr = '';
      descriptionEn = '';
    }

    final thumb = json['thumbnail']?.toString() ?? '';

    thumbnail = thumb.isEmpty
        ? ''
        : thumb.startsWith('http')
        ? thumb
        : '$fileUrl$thumb';

    rating = (json['rating'] is num)
        ? (json['rating'] as num).toDouble()
        : double.tryParse(json['rating']?.toString() ?? '0') ?? 0;

    final category = json['category'];

    if (category is int) {
      categoryID = category;
    } else if (category is Map) {
      categoryID = int.tryParse(category['id']?.toString() ?? '0') ?? 0;
    } else {
      categoryID = int.tryParse(category?.toString() ?? '0') ?? 0;
    }

    final instructor = json['instructor'];

    if (instructor is Map) {
      final firstName = instructor['name']?.toString() ?? '';

      final lastName = instructor['last_name']?.toString() ?? '';

      instructorName = '$firstName $lastName'.trim();
    } else {
      instructorName = '';
    }

    level = json['level']?.toString() ?? '';
  }
}
