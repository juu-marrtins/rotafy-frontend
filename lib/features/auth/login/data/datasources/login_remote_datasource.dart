import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rotafy_frontend/features/auth/register/data/models/user_model.dart';

class LoginRemoteDatasource {
  static const _baseUrl = 'https://nonhedonistically-unmoldy-nelson.ngrok-free.dev/api/v1';

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Origin': 'http://localhost:3000',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data['data']['token'];
    }

    throw Exception(data['message'] ?? 'Erro ao fazer login');
  }
}