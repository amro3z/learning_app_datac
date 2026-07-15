import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:training/constant/strings.dart';
import 'package:training/cubits/states/user_state.dart';
import 'package:training/data/api/api_constant.dart';
import 'package:training/services/network_service.dart';
import 'package:training/services/tokens/api_client.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  final ApiClient _api = ApiClient();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _kUserCacheKey = 'cached_user';

  String? _userId;
  String? get userId => _userId;

  Future<void> login({required String email, required String password}) async {
    emit(UserLoading());

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode != 200) {
        String message = 'Login failed';

        if (decoded is Map<String, dynamic>) {
          final errors = decoded['errors'];

          if (errors is List && errors.isNotEmpty) {
            final firstError = errors.first;

            if (firstError is Map<String, dynamic>) {
              message = firstError['message']?.toString() ?? 'Login failed';
            }
          }
        }

        if (message.contains('Invalid user credentials')) {
          emit(UserError('INVALID_CREDENTIALS'));
        } else if (message.contains('User not found')) {
          emit(UserError('EMAIL_NOT_FOUND'));
        } else {
          emit(UserError('LOGIN_FAILED'));
        }
        return;
      }

      if (decoded is! Map<String, dynamic> ||
          decoded['data'] is! Map<String, dynamic>) {
        emit(UserError('LOGIN_FAILED'));
        return;
      }

      final data = decoded['data'] as Map<String, dynamic>;
      final accessToken = data['access_token']?.toString();
      final refreshToken = data['refresh_token']?.toString();

      if (accessToken == null || refreshToken == null) {
        emit(UserError('LOGIN_FAILED'));
        return;
      }

      await _api.auth.saveTokens(accessToken, refreshToken);
      await _loadCurrentUser();
    } catch (_) {
      emit(UserError('NETWORK_ERROR'));
    }
  }

  Future<void> restoreSession() async {
    await _api.auth.init();

    if (!_api.auth.hasToken) {
      emit(UserInitial());
      return;
    }

    if (!NetworkService.isConnected) {
      final cached = await _readCachedUser();

      if (cached != null) {
        _userId = cached['id']?.toString();
        emit(_mapUser(cached, message: 'Offline mode'));
      } else {
        emit(UserInitial());
      }
      return;
    }

    emit(UserLoading());
    await _loadCurrentUser();
  }

  Future<void> _fetchCurrentUser({String? message}) async {
    final response = await _api.get('$baseUrl/users/me');

    if (response.statusCode != 200) {
      throw Exception('Failed to load user');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> ||
        decoded['data'] is! Map<String, dynamic>) {
      throw Exception('Invalid user response');
    }

    final user = Map<String, dynamic>.from(
      decoded['data'] as Map<String, dynamic>,
    );

    _userId = user['id']?.toString();
    await _cacheUser(user);
    emit(_mapUser(user, message: message));
  }

  Future<void> _loadCurrentUser() async {
    try {
      await _fetchCurrentUser();
    } catch (_) {
      final cached = await _readCachedUser();

      if (cached != null) {
        _userId = cached['id']?.toString();
        emit(_mapUser(cached, message: 'Offline mode'));
      } else {
        emit(UserInitial());
      }
    }
  }

  Future<void> refreshUser({String? message}) async {
    if (!NetworkService.isConnected) {
      final cached = await _readCachedUser();
      if (cached != null) {
        _userId = cached['id']?.toString();
        emit(_mapUser(cached, message: 'Offline mode'));
      }
      return;
    }

    try {
      await _fetchCurrentUser(message: message);
    } catch (_) {
      final cached = await _readCachedUser();
      if (cached != null) {
        _userId = cached['id']?.toString();
        emit(_mapUser(cached, message: 'Offline mode'));
      }
    }
  }

  Future<void> uploadAvatar(File image) async {
    if (!NetworkService.isConnected) return;
    if (_userId == null || state is! UserLoaded) return;

    final current = state as UserLoaded;
    emit(current.copyWith(isUploading: true));

    try {
      final upload = await _uploadProfileImage(image);

      if (upload['success'] != true) {
        emit(current.copyWith(isUploading: false));
        return;
      }

      final response = await _api.patch(
        '$baseUrl/users/$_userId',
        body: {'avatar': upload['fileId']},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        emit(
          current.copyWith(
            isUploading: false,
            message: 'Failed to update avatar',
          ),
        );
        return;
      }

      await _loadCurrentUser();
    } catch (_) {
      emit(current.copyWith(isUploading: false));
    }
  }

  Future<Map<String, dynamic>> _uploadProfileImage(File image) async {
    await _api.auth.init();

    final token = _api.auth.token;
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Missing access token'};
    }

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/files'));

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
        filename: path.basename(image.path),
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic> &&
          decoded['data'] is Map<String, dynamic>) {
        final data = decoded['data'] as Map<String, dynamic>;
        return {'success': true, 'fileId': data['id']};
      }
    }

    return {'success': false, 'message': responseBody};
  }

  Future<void> logout() async {
    await _api.auth.logout();
    await _clearCachedUser();
    _userId = null;
    emit(UserInitial());
  }

  Future<void> _cacheUser(Map<String, dynamic> user) async {
    await _storage.write(key: _kUserCacheKey, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> _readCachedUser() async {
    final raw = await _storage.read(key: _kUserCacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      await _clearCachedUser();
    }

    return null;
  }

  Future<void> _clearCachedUser() async {
    await _storage.delete(key: _kUserCacheKey);
  }

  UserLoaded _mapUser(Map<String, dynamic> user, {String? message}) {
    final avatar = user['avatar'];
    String? avatarId;

    if (avatar is String || avatar is num) {
      avatarId = avatar.toString();
    } else if (avatar is Map && avatar['id'] != null) {
      avatarId = avatar['id'].toString();
    }

    final role = user['role'];
    String? roleName = (role == studentRole
        ? 'student'
        : role == instructorRole
        ? 'instructor'
        : null);

    log("User role: $roleName");
    return UserLoaded(
      Fname: '${user['first_name'] ?? ''}'.trim(),
      Lname: '${user['last_name'] ?? ''}'.trim(),
      email: user['email']?.toString() ?? '',
      avatarUrl: avatarId == null ? null : '$fileUrl$avatarId',
      role: roleName ?? '',
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
      final response = await _api.patch(
        '$baseUrl/users/$_userId',
        body: {'first_name': firstName, 'last_name': lastName},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        emit(
          current.copyWith(
            isUploading: false,
            message: 'Failed to update name',
          ),
        );
        return;
      }

      await refreshUser();
    } catch (_) {
      emit(
        current.copyWith(isUploading: false, message: 'Failed to update name'),
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
