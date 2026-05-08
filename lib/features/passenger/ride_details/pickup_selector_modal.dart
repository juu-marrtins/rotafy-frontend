import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rotafy_frontend/core/http/api_client.dart';


Future<bool> showPickupSelectorModal(
  BuildContext context, {
  required int rideId,
  required double initialLat,
  required double initialLng,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PickupSelectorModal(
      rideId: rideId,
      initialLat: initialLat,
      initialLng: initialLng,
    ),
  );
  return result ?? false;
}

class PickupSelectorModal extends StatefulWidget {
  final int rideId;
  final double initialLat;
  final double initialLng;

  const PickupSelectorModal({
    super.key,
    required this.rideId,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  State<PickupSelectorModal> createState() => _PickupSelectorModalState();
}

class _PickupSelectorModalState extends State<PickupSelectorModal> {
  late LatLng _pickupPoint;
  bool _isLoading = false;
  String? _error;

  String get _tileUrl {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    return 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$token';
  }

  @override
  void initState() {
    super.initState();
    _pickupPoint = LatLng(widget.initialLat, widget.initialLng);
  }

  Future<void> _requestRide() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      final response = await ApiClient.post(
        '/v1/passenger/rides/request',
        {
          'ride_id': widget.rideId,
          'pickup_lat': _pickupPoint.latitude.toString(),
          'pickup_lng': _pickupPoint.longitude.toString(),
        },
      );

      final json = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(json['message'] ?? 'Erro ao solicitar carona');
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Onde você vai esperar?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A2340)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Arraste o mapa para posicionar o pino no seu ponto de embarque',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // Mapa interativo
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _pickupPoint,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture && position.center != null) {
                        setState(() => _pickupPoint = position.center!);
                      }
                    },
                  ),
                  children: [
                    TileLayer(urlTemplate: _tileUrl, userAgentPackageName: 'com.rotafy.app'),
                  ],
                ),

                // Pin fixo no centro
                IgnorePointer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2340),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A2340).withOpacity(0.35),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 24),
                      ),
                      // Sombra do pin no chão
                      Container(
                        width: 3,
                        height: 12,
                        color: const Color(0xFF1A2340),
                      ),
                      Container(
                        width: 10,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),

                // Coordenadas no canto
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                    ),
                    child: Text(
                      '${_pickupPoint.latitude.toStringAsFixed(4)}, ${_pickupPoint.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF1A2340), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Erro
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!, style: const TextStyle(fontSize: 12, color: Color(0xFFE53935))),
                    ),
                  ],
                ),
              ),
            ),

          // Botão confirmar
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _requestRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2340),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Confirmar embarque',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}