import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:rotafy_frontend/core/http/api_client.dart';

class PassengerHomeController extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Perfil
  String? userName;
  String? photoUrl;
  String? userType;
  String? userTitle;

  // Saldo
  String? balance;

  // Próxima corrida
  Map<String, dynamic>? nextRide; 
  String get rideOrigin {
    final ride = nextRide?['ride'] as Map<String, dynamic>?;
    return ride?['origin_city'] ?? '';
  }

  String get rideDestination {
    final ride = nextRide?['ride'] as Map<String, dynamic>?;
    return ride?['destination_city'] ?? '';
  }

  String get rideDriverName {
    final ride = nextRide?['ride'] as Map<String, dynamic>?;
    final driver = ride?['driver'] as Map<String, dynamic>?;
    return driver?['name'] ?? '';
  }

  String get rideDepartureTime {
    final ride = nextRide?['ride'] as Map<String, dynamic>?;
    final departure = ride?['departure_at'];
    if (departure == null) return '';
    final date = DateTime.tryParse(departure);
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get rideDepartureLabel {
    final ride = nextRide?['ride'] as Map<String, dynamic>?;
    final departure = ride?['departure_at'];
    if (departure == null) return '';
    final date = DateTime.tryParse(departure);
    if (date == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rideDay = DateTime(date.year, date.month, date.day);
    
    final diff = rideDay.difference(today).inDays;
    
    if (diff == 0) return 'HOJE';
    if (diff == 1) return 'AMANHÃ';
    if (diff == -1) return 'ONTEM';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> recentHistory = [];

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _loadProfile(),
      _loadBalance(),
      _loadNextRide(),
      _loadHistory(), 
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await ApiClient.get('/v1/profile');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final user = data['data'];
        userName = user['name'];
        photoUrl = user['photo_url'];
        userType = user['user_type'];
        userTitle = user['user_title'];
      }
    } catch (e) {
      print('ERRO PROFILE: $e');
    }
  }

  Future<void> _loadBalance() async {
    try {
      final response = await ApiClient.get('/v1/passenger/wallet/balance');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        balance = data['data'];
      }
    } catch (e) {
      print('ERRO BALANCE: $e');
    }
  }

  Future<void> _loadHistory() async {
    try {
      final response = await ApiClient.get('/v1/passenger/rides/history?page=1&per_page=3');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final list = data['data'] as List;
        recentHistory = list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('ERRO HISTORY: $e');
    }
  }

  Future<void> _loadNextRide() async {
    try {
      final response = await ApiClient.get('/v1/passenger/rides/next');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final raw = data['data'];
        if (raw is List) {
          nextRide = raw.isNotEmpty ? raw.first : null;
        } else if (raw is Map) {
          nextRide = raw as Map<String, dynamic>;
        } else {
          nextRide = null;
        }
      }
    } catch (e) {
      print('ERRO NEXT RIDE: $e');
    }
  }

  String get formattedBalance {
    if (balance == null) return 'R\$ 0,00';
    final value = double.tryParse(balance!) ?? 0.0;
    final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $formatted';
  }

  String get firstName => userName?.split(' ').first ?? '';

  String get rideStatusLabel {
    switch (nextRide?['status']) {
      case 'pending': return 'Pendente';
      case 'confirmed': return 'Confirmada';
      case 'in_progress': return 'Em andamento';
      default: return nextRide?['status'] ?? '';
    }
  }

  String get ridePrice {
    final price = nextRide?['calculated_price'];
    if (price == null) return '';
    final value = double.tryParse(price) ?? 0.0;
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  
}