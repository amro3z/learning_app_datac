import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:training/constant/strings.dart';
import 'package:training/screen/debug_console.dart';

class ApiService {
  

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/auth/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "access_token": data["data"]["access_token"],
          "user": data["data"]["user"],
        };
      }

      final error = jsonDecode(response.body);
      return {
        "success": false,
        "message": error["errors"]?[0]?["message"] ?? "Login failed",
      };
    } catch (e) {
      AppLogger.log("LOGIN ERROR → $e");
      return {"success": false, "message": "Network error"};
    }
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/users/register");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "first_name": firstName,
          "last_name": lastName,
        }),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return {"success": true};
      }

      if (response.body.isNotEmpty) {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error["errors"]?[0]?["message"] ?? "Register failed",
        };
      }

      return {"success": false, "message": "Register failed"};
    } catch (e) {
      AppLogger.log("REGISTER ERROR → $e");
      return {"success": false, "message": "Network error"};
    }
  }

}
