import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rotafy_frontend/core/http/api_client.dart';
import '../model/ride_detail_model.dart';

class RideDetailController extends ChangeNotifier {
  RideDetailModel? _ride;
  bool _isLoading = false;
  String? _error;

  RideDetailModel? get ride => _ride;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(int rideId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get('/v1/passenger/rides/$rideId');
      final json = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(json['message'] ?? 'Erro ao carregar corrida');
      }

      _ride = RideDetailModel.fromJson(json['data']);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String get formattedPrice =>
      'R\$ ${_ride?.costPerPassenger.toStringAsFixed(2).replaceAll('.', ',') ?? '—'}';

  String get formattedDeparture {
    final d = _ride?.departureAt;
    if (d == null) return '—';
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get departureDateLabel {
    final d = _ride?.departureAt;
    if (d == null) return '';
    final now = DateTime.now();
    final diff = DateTime(d.year, d.month, d.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    const months = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
    return '${d.day} ${months[d.month - 1]}';
  }

  String get passengersLabel {
    final requests = _ride?.rideRequests ?? [];
    final accepted = requests.where((r) => r.status == 'accepted').toList();
    if (accepted.isEmpty) return 'Nenhum passageiro confirmado';
    final names = accepted.map((r) => r.passenger.name.split(' ').first).toList();
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]} e ${names[1]}';
    return '${names[0]}, ${names[1]} e mais ${names.length - 2}';
  }

  List<RideRequest> get acceptedPassengers =>
      _ride?.rideRequests.where((r) => r.status == 'accepted').toList() ?? [];
}