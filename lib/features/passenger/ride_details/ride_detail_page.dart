import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotafy_frontend/core/widgets/mapbox_map.dart';
import 'package:rotafy_frontend/features/passenger/ride_details/model/ride_detail_model.dart';
import 'package:rotafy_frontend/features/passenger/ride_details/pickup_selector_modal.dart';
import 'package:rotafy_frontend/features/passenger/ride_details/state/ride_detail_controller.dart';

class RideDetailPage extends StatelessWidget {
  final int rideId;
  const RideDetailPage({super.key, required this.rideId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RideDetailController()..load(rideId),
      child: const _RideDetailView(),
    );
  }
}

class _RideDetailView extends StatelessWidget {
  const _RideDetailView();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RideDetailController>();

    if (ctrl.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A2340),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (ctrl.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A2340),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(ctrl.error!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text('Tentar novamente', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final ride = ctrl.ride!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              MapboxRouteMap(
                originLat: ride.originLat,
                originLng: ride.originLng,
                destinationLat: ride.destinationLat,
                destinationLng: ride.destinationLng,
                originLabel: ride.originCity,
                destinationLabel: ride.destinationCity,
                height: 280,
              ),

              // Label central
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 0,
                right: 0,
                child: const Center(child: _MapLabel()),
              ),

              // Botão voltar
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                child: _BackButton(),
              ),
            ],
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    _DriverSection(ride: ride),
                    const SizedBox(height: 16),
                    _InfoGrid(ctrl: ctrl, ride: ride),
                    const SizedBox(height: 20),
                    _PassengersSection(ctrl: ctrl),
                    const SizedBox(height: 28),
                    _RequestButton(ride: ride),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'DETALHE · MAPA DO TRAJETO',
        style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
        ),
        child: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF1A2340)),
      ),
    );
  }
}

class _DriverSection extends StatelessWidget {
  final RideDetailModel ride;
  const _DriverSection({required this.ride});

  @override
  Widget build(BuildContext context) {
    final driver = ride.driver;
    final vehicle = driver.vehicle;

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF4CAF82),
          backgroundImage: driver.photoUrl != null ? NetworkImage(driver.photoUrl!) : null,
          child: driver.photoUrl == null
              ? Text(driver.initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20))
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A2340)),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                  const SizedBox(width: 3),
                  Text(
                    '${vehicle.model} ${vehicle.year} · ${vehicle.plate}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            _ActionBtn(icon: Icons.chat_bubble_outline_rounded, onTap: () {}),
            const SizedBox(width: 8),
            _ActionBtn(icon: Icons.phone_outlined, onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF7F8FA),
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade600),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final RideDetailController ctrl;
  final RideDetailModel ride;
  const _InfoGrid({required this.ctrl, required this.ride});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.9,
      children: [
        _InfoCard(
          icon: Icons.attach_money_rounded,
          iconColor: const Color(0xFF2E9E5B),
          iconBg: const Color(0xFFE8F5E9),
          value: ctrl.formattedPrice,
          label: 'por pessoa',
          valueColor: const Color(0xFF2E9E5B),
        ),
        _InfoCard(
          icon: Icons.access_time_rounded,
          iconColor: const Color(0xFF1A2340),
          iconBg: const Color(0xFFE8EAF0),
          value: ctrl.formattedDeparture,
          label: 'saída · ${ctrl.departureDateLabel}',
        ),
        _InfoCard(
          icon: Icons.route_rounded,
          iconColor: const Color(0xFF7B61FF),
          iconBg: const Color(0xFFEDE9FF),
          value: '${ride.distanceKm.toStringAsFixed(0)} km',
          label: 'distância',
        ),
        _InfoCard(
          icon: Icons.event_seat_rounded,
          iconColor: const Color(0xFFE07B3A),
          iconBg: const Color(0xFFFFF3E0),
          value: '${ride.availableSeats}',
          label: 'vagas restantes',
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;
  final Color? valueColor;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? const Color(0xFF1A2340),
                  ),
                ),
                Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassengersSection extends StatelessWidget {
  final RideDetailController ctrl;
  const _PassengersSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final passengers = ctrl.acceptedPassengers;
    if (passengers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Passageiros confirmados',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A2340)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 28.0 + (passengers.length - 1) * 22,
              height: 32,
              child: Stack(
                children: passengers.asMap().entries.map((e) {
                  final p = e.value.passenger;
                  return Positioned(
                    left: e.key * 22.0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: _avatarColor(e.key),
                      backgroundImage: p.photoUrl != null ? NetworkImage(p.photoUrl!) : null,
                      child: p.photoUrl == null
                          ? Text(p.initial, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ctrl.passengersLabel,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _avatarColor(int index) {
    const colors = [Color(0xFF4A7FD4), Color(0xFFE07B3A), Color(0xFF4CAF82), Color(0xFF9C27B0)];
    return colors[index % colors.length];
  }
}

class _RequestButton extends StatelessWidget {
  final RideDetailModel ride;
  const _RequestButton({required this.ride});

  bool get _canRequest => ride.status == 'open' && ride.availableSeats > 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canRequest
            ? () async {
                final success = await showPickupSelectorModal(
                  context,
                  rideId: ride.id,
                  initialLat: ride.originLat,
                  initialLng: ride.originLng,
                );

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Sua carona foi solicitada!',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF2E9E5B),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A2340),
          disabledBackgroundColor: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          _canRequest ? 'Solicitar carona' : 'Carona indisponível',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _canRequest ? Colors.white : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}