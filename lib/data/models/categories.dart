import 'package:flutter/material.dart';

class CategoriesModel {
  late int id;
  late String title;
  late String description;
  late Color color;
  late String icon;
  CategoriesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    color = Color(
      int.parse((json['color'] ?? '#2196F3').replaceFirst('#', '0xFF')),
    );
    icon = json['icon'];
  }
}
