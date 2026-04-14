import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rotafy_frontend/core/theme/roy_colors.dart';
import '../state/passenger_home_controller.dart';

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PassengerHomeController()..loadAll(),
      child: Scaffold(
        backgroundColor: RoyColors.blueNavy,
        body: _currentIndex == 0
            ? const _HomeView()
            : const Center(child: Text('Em construção')),
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Inicio', index: 0, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Carteira', index: 3, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.person_rounded, label: 'Perfil', index: 4, currentIndex: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isActive
            ? BoxDecoration(color: RoyColors.blueNavy.withOpacity(0.08), borderRadius: BorderRadius.circular(20))
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? RoyColors.blueNavy : RoyColors.textSecondary),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? RoyColors.blueNavy : RoyColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PassengerHomeController>();

    return ctrl.isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: _Header(ctrl: ctrl),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SearchSection(),
                        const SizedBox(height: 24),
                        _NextRideSection(ctrl: ctrl),
                        const SizedBox(height: 24),
                        _HistorySection(ctrl: ctrl),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}

class _Header extends StatelessWidget {
  final PassengerHomeController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bom dia,', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
                Row(
                  children: [
                    Text(ctrl.firstName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 22)),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: RoyColors.green, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: ctrl.photoUrl != null ? NetworkImage(ctrl.photoUrl!) : null,
                      child: ctrl.photoUrl == null ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Saldo Rotafy', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      Text(ctrl.formattedBalance, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: RoyColors.green, borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Recarregar', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Para onde você vai?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: RoyColors.textPrimary),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(color: RoyColors.blueNavy, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text('Buscar caronas', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NextRideSection extends StatelessWidget {
  final PassengerHomeController ctrl;
  const _NextRideSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próxima carona',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: RoyColors.textPrimary),
        ),
        const SizedBox(height: 12),
        ctrl.nextRide == null ? _emptyRide() : _rideCard(),
      ],
    );
  }

  Widget _emptyRide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
      child: const Center(
        child: Text('Nenhuma carona próxima', style: TextStyle(color: RoyColors.textSecondary, fontSize: 14)),
      ),
    );
  }

  Widget _rideCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7DC42A), Color(0xFFB6D83C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: RoyColors.green.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('🚗', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ctrl.rideStatusLabel.toUpperCase()} · ${ctrl.rideDepartureLabel}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ctrl.rideOrigin} → ${ctrl.rideDestination}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ctrl.rideDepartureTime} · com ${ctrl.rideDriverName} · ${ctrl.ridePrice}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
              child: const Text('Ver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final PassengerHomeController ctrl;
  const _HistorySection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.recentHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Histórico recente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: RoyColors.textPrimary),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text('Ver tudo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RoyColors.green)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          ),
          child: Column(
            children: ctrl.recentHistory.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final ride = item['ride'] as Map<String, dynamic>;
              final driver = item['driver'] as Map<String, dynamic>;
              final request = item['request'] as Map<String, dynamic>;

              final origin = ride['origin_city'] ?? '';
              final destination = ride['destination_city'] ?? '';
              final driverName = driver['name'] ?? '';
              final status = ride['status'] ?? '';
              final price = double.tryParse(request['calculated_price'] ?? '0') ?? 0.0;
              final formattedPrice = 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

              final departure = DateTime.tryParse(ride['departure_at'] ?? '');
              final now = DateTime.now();
              String dateLabel = '';
              if (departure != null) {
                final diff = DateTime(now.year, now.month, now.day)
                    .difference(DateTime(departure.year, departure.month, departure.day))
                    .inDays;
                if (diff == 0) dateLabel = 'Hoje';
                else if (diff == 1) dateLabel = 'Ontem';
                else {
                  const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
                  const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
                  dateLabel = '${weekdays[departure.weekday - 1]}, ${departure.day} ${months[departure.month - 1]}';
                }
              }

              final isCompleted = status == 'completed';
              final statusLabel = isCompleted ? 'Concluída' : 'Avaliar';
              final statusColor = isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);
              final statusBg = isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(isCompleted ? '🚗' : '⭐', style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$origin → $destination',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: RoyColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$dateLabel · $driverName',
                                style: const TextStyle(fontSize: 12, color: RoyColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formattedPrice,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: RoyColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                              child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (i < ctrl.recentHistory.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}