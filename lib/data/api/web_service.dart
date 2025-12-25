import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:training/data/api/api_constant.dart';

class LearningWebservice {
  late Dio dio;
  LearningWebservice() {
    BaseOptions option = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: Duration(milliseconds: 30 * 1000),
      receiveTimeout: Duration(milliseconds: 30 * 1000),
    );
    dio = Dio(option);
  }
  Future<Map<String, dynamic>> getCoursesList() async {
    try {
      Response response = await dio.get('$apiUrl/courses');
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      return {};
    }
  }
}
