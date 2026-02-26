import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:training/cubits/states/user_state.dart';
import 'package:training/data/api/api_constant.dart';
import 'package:training/services/tokens/api_client.dart';
import 'package:training/services/network_service.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  final ApiClient _api = ApiClient();

  String? _userId;
  String? get userId => _userId;

  static const _kUserCacheKey = 'cached_user';

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

      await _loadCurrentUser(); // هيجيب user ويحفظه لوكال
    } catch (_) {
      emit(UserError("Login failed"));
    }
  }

  // ================= RESTORE SESSION =================
  Future<void> restoreSession() async {
    if (!_api.auth.hasToken) return;

    // ✅ لو مفيش نت: رجّع من اللوكال ومترجعش للوجن
    if (!NetworkService.isConnected) {
      final cached = await _readCachedUser();
      if (cached != null) {
        _userId = cached['id']?.toString();
        emit(_mapUser(cached, message: "Offline mode"));
        return;
      }

      // لو مفيش كاش أصلاً، ساعتها بس رجّع لوجن
      emit(UserInitial());
      return;
    }

    emit(UserLoading());
    await _loadCurrentUser();
  }

  // ================= LOAD USER =================
  Future<void> _fetchCurrentUser({String? message}) async {
    final res = await _api.get('$baseUrl/users/me');

    if (res.statusCode != 200) {
      throw Exception('Failed to load user');
    }

    final body = jsonDecode(res.body);
    final user = body["data"] as Map<String, dynamic>;

    _userId = user["id"]?.toString();

    // ✅ خزّن user locally
    await _cacheUser(user);

    emit(_mapUser(user, message: message));
  }

  Future<void> _loadCurrentUser() async {
    try {
      await _fetchCurrentUser();
    } catch (_) {
      // ✅ بدل logout: لو فيه كاش اعرضه، وإلا رجّع لوجن
      final cached = await _readCachedUser();
      if (cached != null) {
        _userId = cached['id']?.toString();
        emit(_mapUser(cached, message: "Offline mode"));
      } else {
        emit(UserInitial());
      }
    }
  }

  Future<void> refreshUser({String? message}) async {
    // لو أوفلاين متعملش request
    if (!NetworkService.isConnected) {
      final cached = await _readCachedUser();
      if (cached != null) {
        emit(_mapUser(cached, message: "Offline mode"));
      }
      return;
    }

    try {
      await _fetchCurrentUser(message: message);
    } catch (_) {
      final cached = await _readCachedUser();
      if (cached != null) {
        emit(_mapUser(cached, message: "Offline mode"));
      }
    }
  }

  // ================= UPLOAD AVATAR =================
  Future<void> uploadAvatar(File image) async {
    if (!NetworkService.isConnected) return;
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
    await _clearCachedUser();
    _userId = null;
    emit(UserInitial());
  }

  // ================= CACHE HELPERS =================
  Future<void> _cacheUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserCacheKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> _readCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUserCacheKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  Future<void> _clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserCacheKey);
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
      avatarUrl: avatarId == null ? null : '$fileUrl$avatarId',
      isUploading: false,
      message: message,
    );
  }

  Future<void> updateName({
    required String firstName,
    required String lastName,
  }) async {
    if (!NetworkService.isConnected) return;
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
    if (!NetworkService.isConnected) return false;
    if (_userId == null) return false;

    try {
      final response = await _api.delete('$baseUrl/users/$_userId');

      if (response.statusCode == 204 || response.statusCode == 200) {
        await _api.auth.logout();
        await _clearCachedUser();
        _userId = null;
        emit(UserInitial());
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
