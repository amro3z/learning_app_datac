import 'package:training/data/api/api_constant.dart';

class CategoriesModel {
  late int id;
  late String title;
  late String description;
  late String thumbnail;
  CategoriesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    thumbnail =  '$fileUrl${json['thumbnail']}';
  }
}