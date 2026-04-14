import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';
import 'package:rotafy_frontend/core/http/api_client.dart';

class RegisterController extends ChangeNotifier {
	int _currentStep = 0;
	int get currentStep => _currentStep;

	final nameController = TextEditingController();
	final emailController = TextEditingController();
	final cpfController = TextEditingController();
	final phoneController = TextEditingController();
	final cnpjController = TextEditingController();
	final academicProfileController = TextEditingController();
	final passwordController = TextEditingController();

	String? selectedProfile;
	Uint8List? photoBytes;
	String? photoFileName;
	VoidCallback? onSuccess;

	bool _isLoading = false;
	bool get isLoading => _isLoading;

	String? _errorMessage;
	String? get errorMessage => _errorMessage;

	void goToStep(int step) {
		_currentStep = step;
		notifyListeners();
	}

	void setPhoto(Uint8List bytes, String fileName) {
		photoBytes = bytes;
		photoFileName = fileName;
		notifyListeners();
	}

	void setProfile(String profile) {
		selectedProfile = profile;
		notifyListeners();
	}

	bool validateStep1() {
		if (nameController.text.trim().isEmpty) {
		_errorMessage = 'Informe seu nome';
		notifyListeners();
		return false;
		}
		if (cpfController.text.length < 14) {
		_errorMessage = 'CPF inválido';
		notifyListeners();
		return false;
		}
		_errorMessage = null;
		return true;
	}

	bool validateStep2() {
		if (cnpjController.text.length < 18) {
		_errorMessage = 'CNPJ inválido';
		notifyListeners();
		return false;
		}
		if (selectedProfile == null) {
		_errorMessage = 'Selecione um perfil acadêmico';
		notifyListeners();
		return false;
		}
		if (passwordController.text.length < 6) {
		_errorMessage = 'A senha deve ter pelo menos 6 dígitos';
		notifyListeners();
		return false;
		}
		_errorMessage = null;
		return true;
	}

	void nextStep() {
		if (_currentStep == 0 && !validateStep1()) return;
		if (_currentStep == 1 && !validateStep2()) return;
		if (_currentStep < 1) {
		_currentStep++;
		notifyListeners();
		}
	}

	Future<void> submit() async {
		_isLoading = true;
		_errorMessage = null;
		notifyListeners();

		try {
		final response = await ApiClient.multipart(
				'/v1/auth/register',
				{
				'name': nameController.text.trim(),
				'email': emailController.text.trim(),
				'cpf': cpfController.text.trim(),
				'cnpj': cnpjController.text.trim(),
				'password': passwordController.text.trim(),
				'type': 'passenger',
				'title': selectedProfile ?? '',
				'phone': phoneController.text.trim(),
				'terms_accepted': 'true',
				},
				files: photoBytes != null
						? [http.MultipartFile.fromBytes('photo', photoBytes!, filename: photoFileName ?? 'photo.jpg')]
						: [],
		);

		final body = await response.stream.bytesToString();
		final data = jsonDecode(body);

		if (response.statusCode == 200 || response.statusCode == 201) {
				_errorMessage = null;
				onSuccess?.call();
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
		nameController.dispose();
		emailController.dispose();
		cpfController.dispose();
		phoneController.dispose();
		cnpjController.dispose();
		passwordController.dispose();
		academicProfileController.dispose();
		super.dispose();
	}
}