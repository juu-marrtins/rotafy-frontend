import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

abstract class RegisterRemoteDatasource {
	Future<void> register(UserModel user);
}

class RegisterRemoteDatasourceImpl implements RegisterRemoteDatasource {
	final _baseUrl = String.fromEnvironment('API_URL');

	@override
	Future<void> register(UserModel user) async {
		final response = await http.post(
			Uri.parse('$_baseUrl/v1/auth/register'),
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode(user.toJson()),
			);
			
			if (response.statusCode != 201) {
				throw Exception('Falha no cadastro: ${response.body}');
			}

		await Future.delayed(const Duration(seconds: 1));
	}
}