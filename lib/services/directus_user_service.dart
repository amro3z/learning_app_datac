import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:training/constant/strings.dart';
import 'package:training/data/api/api_constant.dart';
import 'package:training/screen/debug_console.dart';

class ApiService {
  Future<Map<String, dynamic>> getCurrentUser({
    required String accessToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/users/me');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "user": data["data"]};
      }

      return {"success": false};
    } catch (e) {
      return {"success": false};
    }
  }

  // ================= REGISTER =================
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required bool isInstructor,
    String? specialization,
    String? grade,
  }) async {
    try {
      final addUser = await http.post(
        Uri.parse(registerUrl),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "first_name": firstName,
          "last_name": lastName,
          "status": "active",
          "role": isInstructor ? instructorRole : studentRole,
        }),
      );

      final Map<String, dynamic> userBody =
          jsonDecode(addUser.body) as Map<String, dynamic>;

      if (addUser.statusCode < 200 || addUser.statusCode >= 300) {
        if (userBody["errors"] != null) {
          final error = userBody["errors"][0];

          if (error["extensions"]?["code"] == "RECORD_NOT_UNIQUE") {
            return {
              "success": false,
              "emailExists": true,
              "message": "Email already exists",
            };
          }

          return {
            "success": false,
            "message": error["message"] ?? "Register failed",
          };
        }

        return {
          "success": false,
          "message": "Failed to create user: ${addUser.body}",
        };
      }

      final userData = userBody["data"];

      if (userData == null || userData["id"] == null) {
        return {
          "success": false,
          "message": "User created but user ID was not returned",
        };
      }

      final String userId = userData["id"].toString();

      late final http.Response profileResponse;

      if (isInstructor) {
        if (specialization == null || specialization.trim().isEmpty) {
          return {
            "success": false,
            "message": "Specialization is required",
            "registrationSuccess": true,
          };
        }

        profileResponse = await http.post(
          Uri.parse('$baseUrl/items/instructors'),
          headers: const {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": firstName,
            "last_name": lastName,
            "email": email,
            "user": userId,
            "specialization": specialization,
          }),
        );
      } else {
        if (grade == null || grade.trim().isEmpty) {
          return {
            "success": false,
            "message": "Grade is required",
            "registrationSuccess": true,
          };
        }

        profileResponse = await http.post(
          Uri.parse('$baseUrl/items/student'),
          headers: const {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": firstName,
            "last_name": lastName,
            "email": email,
            "user": userId,
            "grade": grade,
          }),
        );
      }

      final Map<String, dynamic> profileBody =
          jsonDecode(profileResponse.body) as Map<String, dynamic>;

      if (profileResponse.statusCode < 200 ||
          profileResponse.statusCode >= 300) {
        final errors = profileBody["errors"];

        return {
          "success": false,
          "registrationSuccess": true,
          "message": errors != null
              ? errors[0]["message"] ?? "Failed to create profile"
              : "Failed to create profile: ${profileResponse.body}",
        };
      }

      return {
        "success": true,
        "user": userData,
        "profile": profileBody["data"],
        "accountType": isInstructor ? "instructor" : "student",
      };
    } catch (e, stackTrace) {
      log('REGISTER ERROR', error: e, stackTrace: stackTrace);

      return {"success": false, "message": "Network error: $e"};
    }
  }

  // ================= UPLOAD IMAGE =================
  Future<Map<String, dynamic>> uploadProfileImage({
    required File image,
    required String accessToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/files');

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $accessToken';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          filename: path.basename(image.path),
        ),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        return {"success": true, "fileId": data["data"]["id"]};
      }

      return {"success": false, "message": "Upload failed"};
    } catch (e) {
      AppLogger.log("UPLOAD IMAGE ERROR → $e");
      return {"success": false, "message": "Network error"};
    }
  }

  // ================= UPDATE USER AVATAR =================
  Future<Map<String, dynamic>> updateUserAvatar({
    required String userId,
    required String fileId,
    required String accessToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/users/$userId');

      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"avatar": fileId}),
      );

      if (response.statusCode == 200) {
        return {"success": true};
      }

      return {"success": false, "message": response.body};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
