import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:training/services/tokens/auths_service.dart';

class ApiClient {
  final AuthService _auth = AuthService();
  AuthService get auth => _auth; 

  Future<http.Response> get(String url) async {
    final res = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer ${_auth.token}"},
    );

    if (_isExpired(res)) {
      final ok = await _auth.refreshTokenIfNeeded();
      if (!ok) throw Exception("Session expired");

      return http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${_auth.token}"},
      );
    }

    return res;
  }

Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final res = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer ${_auth.token}",
        "Content-Type": "application/json",
        ...?headers,
      },
      body: body,
    );

    if (_isExpired(res)) {
      final ok = await _auth.refreshTokenIfNeeded();
      if (!ok) throw Exception("Session expired");

      return http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${_auth.token}",
          "Content-Type": "application/json",
          ...?headers,
        },
        body: body,
      );
    }

    return res;
  }

  Future<http.Response> delete(
  String url, {
  Map<String, String>? headers,
  Object? body,
}) async {
  final res = await http.delete(
    Uri.parse(url),
    headers: {
      "Authorization": "Bearer ${_auth.token}",
      "Content-Type": "application/json",
      ...?headers,
    },
    body: body,
  );

  if (_isExpired(res)) {
    final ok = await _auth.refreshTokenIfNeeded();
    if (!ok) throw Exception("Session expired");

    return http.delete(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer ${_auth.token}",
        "Content-Type": "application/json",
        ...?headers,
      },
      body: body,
    );
  }

  return res;
}


  Future<http.Response> patch(
    String url, {
    required Map<String, dynamic> body,
  }) async {
    final res = await http.patch(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer ${_auth.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (_isExpired(res)) {
      final ok = await _auth.refreshTokenIfNeeded();
      if (!ok) throw Exception("Session expired");

      return http.patch(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${_auth.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    }

    return res;
  }

  bool _isExpired(http.Response res) {
    if (res.statusCode == 401) return true;
    try {
      final body = jsonDecode(res.body);
      return body['errors']?[0]?['extensions']?['code'] == 'TOKEN_EXPIRED';
    } catch (_) {
      return false;
    }
  }
}
