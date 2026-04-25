import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:rotafy_frontend/core/http/api_client.dart';

class SearchRidesController extends ChangeNotifier {
  final originController = TextEditingController();
  final destinationController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasSearched = false;
  bool get hasSearched => _hasSearched;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> rides = [];

  String _selectedFilter = 'Todos';
  String get selectedFilter => _selectedFilter;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredRides {
    if (_selectedFilter == 'Todos') return rides;
    return rides.where((ride) {
      final departure = DateTime.tryParse(ride['departure_at'] ?? '');
      if (departure == null) return false;
      final hour = departure.hour;
      if (_selectedFilter == 'Manhã') return hour >= 5 && hour < 12;
      if (_selectedFilter == 'Tarde') return hour >= 12 && hour < 18;
      if (_selectedFilter == 'Noite') return hour >= 18 || hour < 5;
      return true;
    }).toList();
  }

  Future<void> search() async {
    if (originController.text.trim().isEmpty || destinationController.text.trim().isEmpty) {
      _errorMessage = 'Informe origem e destino';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _hasSearched = false;
    notifyListeners();

    try {
      final origin = Uri.encodeComponent(originController.text.trim());
      final destination = Uri.encodeComponent(destinationController.text.trim());
      final response = await ApiClient.get('/v1/passenger/rides/search?origin=$origin&destination=$destination');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final list = data['data'] as List;
        rides = list.map((e) => e as Map<String, dynamic>).toList();
        _hasSearched = true;
      } else {
        _errorMessage = data['message'] ?? 'Erro ao buscar caronas';
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão';
      print('ERRO SEARCH: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatDepartureTime(String? departure) {
    if (departure == null) return '';
    final date = DateTime.tryParse(departure);
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String formatPrice(dynamic price) {
    final value = double.tryParse(price.toString()) ?? 0.0;
    return 'R\$${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String driverInitial(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    super.dispose();
  }
}