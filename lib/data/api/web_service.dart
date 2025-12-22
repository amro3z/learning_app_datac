import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:training/constant/strings.dart';

class LearningWebservice {
  late Dio dio;
  LearningWebservice() {
    BaseOptions option = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: Duration(milliseconds: 30 * 1000), // 30 seconds
      receiveTimeout: Duration(milliseconds: 30 * 1000), // 30 seconds
    );
    dio = Dio(option);
  }
  Future<Map<String, dynamic>> getCoursesList() async {
    try {
      Response response = await dio.get('items/courses');
      return response.data;
    } catch (e) {
      log(e.toString());
      return {};
    }
  }
}
