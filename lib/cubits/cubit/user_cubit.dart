import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:training/cubits/states/user_state.dart';
import 'package:training/data/api/api_constant.dart';
import 'package:training/services/tokens/api_client.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  final ApiClient _api = ApiClient();
  String? _userId;
  String? get userId => _userId;
  // ================= LOGIN =================
  Future<void> login({required String email, required String password}) async {
    emit(UserLoading());

    try {
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
      await _api.auth.saveTokens(
        body["data"]["access_token"],
        body["data"]["refresh_token"],
      );

      await _loadCurrentUser();
    } catch (_) {
      emit(UserError("Login failed"));
    }
  }

  // ================= RESTORE SESSION =================
  Future<void> restoreSession() async {
    if (!_api.auth.hasToken) return;

    emit(UserLoading());
    await _loadCurrentUser();
  }

  // ================= LOAD USER =================
  Future<void> _fetchCurrentUser({
    String? message,
    bool logoutOnError = false,
  }) async {
    try {
      final res = await _api.get('$baseUrl/users/me');

      final body = jsonDecode(res.body);
      final user = body["data"];
      _userId = user["id"];

      emit(_mapUser(user, message: message));
    } catch (_) {
      if (logoutOnError) {
        await logout();
      } else {
        emit(UserError("Session expired"));
      }
    }
  }

Future<void> _loadCurrentUser() async {
    await _fetchCurrentUser(logoutOnError: true);
  }


Future<void> refreshUser({String? message}) async {
    await _fetchCurrentUser(message: message);
  }


  // ================= UPLOAD AVATAR =================
  Future<void> uploadAvatar(File image) async {
    if (_userId == null || state is! UserLoaded) return;

    final current = state as UserLoaded;
    emit(current.copyWith(isUploading: true));

    try {
      final upload = await _uploadProfileImage(image);
      if (!upload['success']) {
        emit(current.copyWith(isUploading: false));
        return;
      }

      await _api.patch(
        '$baseUrl/users/$_userId',
        body: {"avatar": upload['fileId']},
      );

      await _loadCurrentUser();
    } catch (_) {
      emit(current.copyWith(isUploading: false));
    }
  }

  // ================= FILE UPLOAD =================
  Future<Map<String, dynamic>> _uploadProfileImage(File image) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/files'));

    request.headers['Authorization'] = 'Bearer ${_api.auth.token}';

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

    return {"success": false};
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _api.auth.logout();
    _userId = null;
    emit(UserInitial());
  }

  // ================= MAPPER =================
  UserLoaded _mapUser(Map<String, dynamic> user, {String? message}) {
    final avatar = user["avatar"];
    String? avatarId;

    if (avatar is String || avatar is num) {
      avatarId = avatar.toString();
    } else if (avatar is Map && avatar["id"] != null) {
      avatarId = avatar["id"].toString();
    }

    return UserLoaded(
      name: '${user["first_name"] ?? ""} ${user["last_name"] ?? ""}'.trim(),
      email: user["email"] ?? "",
      avatarUrl: avatarId == null
          ? null
          : '$fileUrl$avatarId?v=${DateTime.now().millisecondsSinceEpoch}',
      isUploading: false,
      message: message,
    );
  }

  Future<void> updateName({
    required String firstName,
    required String lastName,
  }) async {
    if (_userId == null || state is! UserLoaded) return;

    final current = state as UserLoaded;

    emit(current.copyWith(isUploading: true));

    try {
      await _api.patch(
        '$baseUrl/users/$_userId',
        body: {"first_name": firstName, "last_name": lastName},
      );

      await refreshUser();
    } catch (_) {
      emit(
        current.copyWith(isUploading: false, message: "Failed to update name"),
      );
    }
  }
Future<bool> deleteAccount() async {
    if (_userId == null) return false;

    try {
      final response = await _api.delete('$baseUrl/users/$_userId');

      if (response.statusCode == 204 || response.statusCode == 200) {
        await _api.auth.logout();
        _userId = null;
        emit(UserInitial());
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }



}
