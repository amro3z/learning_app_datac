import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
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
  }) async {
    try {
      final url = Uri.parse(registerUrl);

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

      final body = jsonDecode(response.body);

      if (body["data"] != null) {
        return {"success": true, "user": body["data"]};
      }

      if (body["errors"] != null) {
        final error = body["errors"][0];

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

      return {"success": false, "message": "Register failed"};
    } catch (e) {
      AppLogger.log("REGISTER ERROR → $e");
      return {"success": false, "message": "Network error"};
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
