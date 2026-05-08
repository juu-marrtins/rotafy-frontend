import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:rotafy_frontend/core/http/api_client.dart';
import 'package:rotafy_frontend/router/app_router.dart';
import 'package:rotafy_frontend/core/services/auth_storage.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  VoidCallback? onSuccess;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<void> submit() async {
    if (emailController.text.trim().isEmpty) {
      _errorMessage = 'Informe seu e-mail';
      notifyListeners();
      return;
    }
    if (passwordController.text.length < 6) {
      _errorMessage = 'Senha inválida';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.post('/v1/auth/login', {
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      });
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = data['data']['token'];

        if (_rememberMe) {
          await AuthStorage.saveToken(token);
        } else {
          await AuthStorage.saveSessionToken(token);
        }
        await refreshAuth(); 
        onSuccess?.call();

        onSuccess?.call();
      } else if (response.statusCode == 401) {
        _errorMessage = 'Credenciais inválidas. Confira seus dados.';
      } else {
        _errorMessage = data['message'];
      }
    } catch (e) {
      _errorMessage = 'Erro: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}