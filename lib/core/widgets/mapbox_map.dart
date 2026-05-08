import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapboxRouteMap extends StatefulWidget {
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final double height;
  final bool interactive;
  final String? originLabel;
  final String? destinationLabel;

  const MapboxRouteMap({
    super.key,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    this.height = 280,
    this.interactive = false,
    this.originLabel,
    this.destinationLabel,
  });

  @override
  State<MapboxRouteMap> createState() => _MapboxRouteMapState();
}

class _MapboxRouteMapState extends State<MapboxRouteMap> {
  List<LatLng> _routePoints = [];
  bool _loadingRoute = true;

  LatLng get _origin => LatLng(widget.originLat, widget.originLng);
  LatLng get _destination => LatLng(widget.destinationLat, widget.destinationLng);
  LatLng get _center => LatLng(
        (widget.originLat + widget.destinationLat) / 2,
        (widget.originLng + widget.destinationLng) / 2,
      );

  double get _zoom {
    final latDiff = (widget.originLat - widget.destinationLat).abs();
    final lngDiff = (widget.originLng - widget.destinationLng).abs();
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    if (maxDiff > 2) return 7.0;
    if (maxDiff > 1) return 8.0;
    if (maxDiff > 0.5) return 9.0;
    return 10.5;
  }

  String get _tileUrl {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    return 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$token';
  }

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '${widget.originLng},${widget.originLat};'
        '${widget.destinationLng},${widget.destinationLat}'
        '?geometries=geojson&overview=full&access_token=$token';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        setState(() {
          _routePoints = coords
              .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();
          _loadingRoute = false;
        });
      } else {
        _fallback();
      }
    } catch (_) {
      _fallback();
    }
  }

  void _fallback() => setState(() { _routePoints = [_origin, _destination]; _loadingRoute = false; });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Mapa
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              interactionOptions: InteractionOptions(
                flags: widget.interactive ? InteractiveFlag.all : InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(urlTemplate: _tileUrl, userAgentPackageName: 'com.rotafy.app'),

              // Glow da rota
              if (!_loadingRoute)
                PolylineLayer(polylines: [
                  Polyline(
                    points: _routePoints,
                    color: const Color(0xFF1A2340).withOpacity(0.12),
                    strokeWidth: 14,
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ]),

              // Rota principal
              if (!_loadingRoute)
                PolylineLayer(polylines: [
                  Polyline(
                    points: _routePoints,
                    color: const Color(0xFF1A2340),
                    strokeWidth: 4.5,
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ]),

              // Marcadores
              MarkerLayer(markers: [
                // Origem — círculo verde com ícone de pessoa
                Marker(
                  point: _origin,
                  width: 40,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF82),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF4CAF82).withOpacity(0.4), blurRadius: 10, spreadRadius: 2),
                      ],
                    ),
                    child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 20),
                  ),
                ),

                // Destino — pin azul escuro com bandeira
                Marker(
                  point: _destination,
                  width: 40,
                  height: 52,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFE53935).withOpacity(0.4), blurRadius: 10, spreadRadius: 2),
                          ],
                        ),
                        child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
                      ),
                      // Ponteiro
                      Container(
                        width: 3,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ],
          ),

          // Loading
          if (_loadingRoute)
            Container(
              color: Colors.white.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF1A2340), strokeWidth: 2)),
            ),

          // Gradiente inferior
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: IgnorePointer(
              child: Container(
                height: 90,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0.2, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Label origem
          if (widget.originLabel != null)
            Positioned(
              top: 12, left: 12,
              child: _CityChip(label: widget.originLabel!, icon: Icons.trip_origin_rounded, color: const Color(0xFF4CAF82)),
            ),

          // Label destino
          if (widget.destinationLabel != null)
            Positioned(
              top: 12, right: 12,
              child: _CityChip(label: widget.destinationLabel!, icon: Icons.location_on_rounded, color: const Color(0xFFE53935)),
            ),
        ],
      ),
    );
  }
}

// ─── Chip de cidade ───────────────────────────────────────────────────────────
class _CityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _CityChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1A2340))),
        ],
      ),
    );
  }
}