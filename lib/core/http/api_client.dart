import 'package:http/http.dart' as http;
import 'package:rotafy_frontend/core/services/auth_storage.dart';
import 'dart:convert';

class ApiClient {
  static const _baseUrl = 'https://nonhedonistically-unmoldy-nelson.ngrok-free.dev/api';

  static Map<String, String> get _defaultHeaders => {
    'Accept': 'application/json',
    'Origin': 'http://localhost:3000',
    'ngrok-skip-browser-warning': 'true',
  };

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    return {
      ..._defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String path) async {
    return http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _authHeaders(),
    );
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    return http.post(
      Uri.parse('$_baseUrl$path'),
      headers: {
        ...await _authHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.StreamedResponse> multipart(
    String path,
    Map<String, String> fields, {
    List<http.MultipartFile> files = const [],
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$path'));
    request.headers.addAll(await _authHeaders());
    request.fields.addAll(fields);
    request.files.addAll(files);
    return request.send();
  }
}