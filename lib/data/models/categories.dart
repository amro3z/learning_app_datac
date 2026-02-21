import 'package:flutter/material.dart';

class CategoriesModel {
  late int id;
  late String titleAr;
  late String titleEn;
  late Color color;
  late String icon;
  CategoriesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titleAr = json['title']['ar'];
    titleEn = json['title']['en'];
    color = Color(
      int.parse((json['color'] ?? '#2196F3').replaceFirst('#', '0xFF')),
    );
    icon = json['icon'];
  }
}
