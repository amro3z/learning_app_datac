import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:training/cubits/states/user_state.dart';
import 'package:training/data/api/api_constant.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  String? _token;
  String? _userId;
  static const _kTokenKey = 'auth_token';
  static const _kUserIdKey = 'auth_user_id';

  // ================= LOGIN =================
  Future<void> login({required String email, required String password}) async {
    emit(UserLoading());

    final res = await http.post(
      Uri.parse(loginUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode != 200) {
      emit(UserError("Login failed"));
      return;
    }

    final body = jsonDecode(res.body);
    _token = body["data"]["access_token"];

    await _loadCurrentUser();
  }

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_kTokenKey);
    final savedUserId = prefs.getString(_kUserIdKey);
    if (savedToken == null) return;

    _token = savedToken;
    _userId = savedUserId;
    emit(UserLoading());
    await _loadCurrentUser();
  }

  // ================= LOAD USER =================
  Future<void> _loadCurrentUser({
    String? infoMessage,
    String? expectedAvatarId,
    String? optimisticAvatarUrl,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {"Authorization": "Bearer $_token"},
    );

    if (res.statusCode != 200) {
      emit(UserError("Failed to load user"));
      return;
    }

    final body = jsonDecode(res.body);
    final user = body["data"];
    _userId = user["id"];
    await _persistAuth();

    // extract avatar id
    final avatarField = user["avatar"];
    String? apiAvatarId;
    if (avatarField is String || avatarField is num) {
      apiAvatarId = avatarField.toString();
    } else if (avatarField is Map<String, dynamic>) {
      final id = avatarField["id"];
      if (id is String || id is num) {
        apiAvatarId = id.toString();
      }
    }

    // prefer optimistic avatar when API still returns old avatar
    String? finalAvatarUrl = _buildAvatarUrl(apiAvatarId);
    if (expectedAvatarId != null &&
        optimisticAvatarUrl != null &&
        apiAvatarId != expectedAvatarId) {
      finalAvatarUrl = optimisticAvatarUrl;
    }

    emit(_mapUser(user, message: infoMessage, avatarUrl: finalAvatarUrl));
  }

  // ================= LOGOUT =================
  void logout() {
    _token = null;
    _userId = null;
    _clearAuth();
    emit(UserInitial());
  }

  // ================= MANUAL REFRESH =================
  Future<void> refreshUser({String? message}) async {
    if (_token == null) return;
    await _loadCurrentUser(infoMessage: message);
  }

  // ================= UPLOAD AVATAR (FIX) =================
  Future<void> uploadAvatar(File image) async {
    if (_token == null || _userId == null) return;
    if (state is! UserLoaded) return;

    final currentState = state as UserLoaded;
    emit(
      currentState.copyWith(isUploading: true, message: "جاري رفع الصورة..."),
    );

    // 1️⃣ upload file
    final uploadResult = await _uploadProfileImage(image);
    if (uploadResult['success'] != true || uploadResult['fileId'] == null) {
      emit(
        currentState.copyWith(
          isUploading: false,
          message: uploadResult['message'] ?? "فشل رفع الصورة",
        ),
      );
      return;
    }

    final fileId = uploadResult['fileId'].toString();

    // 2️⃣ update user avatar
    final updateResult = await _updateUserAvatar(fileId: fileId);
    if (updateResult['success'] != true) {
      emit(
        currentState.copyWith(
          isUploading: false,
          message: updateResult['message'] ?? "فشل تحديث الصورة",
        ),
      );
      return;
    }

    // 3️⃣ update UI immediately with new avatar
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    await _evictImage(currentState.avatarUrl);
    emit(
      currentState.copyWith(
        isUploading: false,
        avatarUrl: '$fileUrl$fileId?v=$cacheBuster',
        message: "تم تحديث الصورة بنجاح",
      ),
    );

    // 4️⃣ reload user from API; keep optimistic avatar if API still returns the old one
    await _loadCurrentUser(
      infoMessage: "تم تحديث الصورة بنجاح",
      expectedAvatarId: fileId,
      optimisticAvatarUrl: '$fileUrl$fileId?v=$cacheBuster',
    );
  }

  // ================= HELPERS =================
  Future<Map<String, dynamic>> _uploadProfileImage(File image) async {
    try {
      final url = Uri.parse('$baseUrl/files');

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $_token';

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
      return {"success": false, "message": "Network error"};
    }
  }

  Future<Map<String, dynamic>> _updateUserAvatar({
    required String fileId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/users/$_userId');

      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $_token",
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

  Future<void> _persistAuth() async {
    if (_token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, _token!);
    if (_userId != null) await prefs.setString(_kUserIdKey, _userId!);
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserIdKey);
  }

  Future<void> _evictImage(String? url) async {
    if (url == null) return;
    try {
      final provider = NetworkImage(url);
      await provider.evict();
    } catch (_) {
      // ignore cache eviction errors
    }
  }

  // ================= MAPPER =================
  UserLoaded _mapUser(
    Map<String, dynamic> user, {
    String? message,
    String? avatarUrl,
  }) {
    return UserLoaded(
      name: '${user["first_name"] ?? ""} ${user["last_name"] ?? ""}'.trim(),
      email: user["email"] ?? "",
      avatarUrl: avatarUrl ?? _buildAvatarUrl(_extractAvatarId(user)),
      isUploading: false,
      message: message,
    );
  }

  String? _extractAvatarId(Map<String, dynamic> user) {
    final avatarField = user["avatar"];
    if (avatarField is String || avatarField is num)
      return avatarField.toString();
    if (avatarField is Map<String, dynamic>) {
      final id = avatarField["id"];
      if (id is String || id is num) return id.toString();
    }
    return null;
  }

  String? _buildAvatarUrl(String? avatarId) {
    if (avatarId == null) return null;
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    return '$fileUrl$avatarId?v=$cacheBuster';
  }
}
