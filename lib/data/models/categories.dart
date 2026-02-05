import 'package:flutter/material.dart';

class CategoriesModel {
  late int id;
  late String title;
  late String description;
  late Color color;

  CategoriesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    color = Color(int.parse(json['color'].replaceFirst('#', '0xFF')));
  }
}
