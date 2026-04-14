import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class AuthService {
  static const _baseUrl = 'https://nonhedonistically-unmoldy-nelson.ngrok-free.dev/api';

  static Future<bool> isAuthenticated() async {
    final token = await AuthStorage.getToken();
    if (token == null) return false;

    final response = await http.get(
      Uri.parse('$_baseUrl/v1/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) return true;

    // Token expirado — limpa
    await AuthStorage.clearToken();
    return false;
  }
}