import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rotafy_frontend/core/theme/roy_colors.dart';
import '../state/search_rides_controller.dart';
import 'package:rotafy_frontend/widgets/bottom_nav.dart';

class SearchRidesPage extends StatelessWidget {
  const SearchRidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchRidesController(),
      child: const _SearchRidesView(),
    );
  }
}

class _SearchRidesView extends StatelessWidget {
  const _SearchRidesView();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SearchRidesController>();

    return Scaffold(
      backgroundColor: RoyColors.blueNavy,
      bottomNavigationBar: BottomNav(
        currentIndex: 0, 
        onTap: (i) {
          if (i == 0) context.go('/home');
          if (i == 3) context.go('/wallet');
          if (i == 4) context.go('/profile');
        },
      ),
      body: Column(
        children: [
          // Header azul
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: _SearchHeader(ctrl: ctrl),
            ),
          ),

          // Bloco branco
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: ctrl.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !ctrl.hasSearched
                      ? const _EmptyState()
                      : _ResultsList(ctrl: ctrl),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final SearchRidesController ctrl;
  const _SearchHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Caronas disponíveis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, color: Colors.white, size: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: ctrl.originController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Sua cidade',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Column(
                  children: List.generate(3, (i) => Container(
                    width: 1,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: Colors.white.withOpacity(0.3),
                  )),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.circle, color: Color(0xFFB6D83C), size: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: ctrl.destinationController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Destino frequente',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => ctrl.search(),
                    ),
                  ),
                  GestureDetector(
                    onTap: ctrl.search,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: RoyColors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Buscar',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔍', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text(
            'Busque uma carona',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: RoyColors.textPrimary),
          ),
          SizedBox(height: 8),
          Text(
            'Informe origem e destino para encontrar caronas disponíveis',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: RoyColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final SearchRidesController ctrl;
  const _ResultsList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final rides = ctrl.filteredRides;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todos', 'Manhã 🌤', 'Tarde ☀️', 'Noite 🌙'].map((filter) {
                final isActive = ctrl.selectedFilter == filter.split(' ')[0];
                return GestureDetector(
                  onTap: () => ctrl.setFilter(filter.split(' ')[0]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? RoyColors.blueNavy : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : RoyColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Text(
            '${rides.length} carona${rides.length != 1 ? 's' : ''} encontrada${rides.length != 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 12, color: RoyColors.textSecondary),
          ),
        ),

        Expanded(
          child: rides.isEmpty
              ? const Center(
                  child: Text('Nenhuma carona encontrada', style: TextStyle(color: RoyColors.textSecondary)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  itemCount: rides.length,
                  itemBuilder: (context, i) => _RideCard(ride: rides[i], ctrl: ctrl),
                ),
        ),
      ],
    );
  }
}

class _RideCard extends StatelessWidget {
  final Map<String, dynamic> ride;
  final SearchRidesController ctrl;
  const _RideCard({required this.ride, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final driver = ride['driver'] as Map<String, dynamic>;
    final driverName = driver['name'] ?? '';
    final photoUrl = driver['photo_url'];
    final rating = ride['driver_rating_avg'];
    final seats = ride['avaliable_seats'] ?? 0;
    final price = ctrl.formatPrice(ride['cost_per_passenger']);
    final time = ctrl.formatDepartureTime(ride['departure_at']);
    final initial = ctrl.driverInitial(driverName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: RoyColors.green, width: 3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: RoyColors.blueNavy,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driverName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: RoyColors.textPrimary)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                          const SizedBox(width: 2),
                          Text(
                            rating != null ? rating.toStringAsFixed(1) : 'Novo',
                            style: const TextStyle(fontSize: 12, color: RoyColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: RoyColors.green)),
                    const Text('por pessoa', style: TextStyle(fontSize: 10, color: RoyColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(icon: Icons.access_time, label: time),
                const SizedBox(width: 12),
                _InfoChip(icon: Icons.people, label: '$seats vagas'),
                const SizedBox(width: 12),
                _InfoChip(icon: Icons.directions_car, label: 'Carro'),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: RoyColors.blueNavy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Solicitar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: RoyColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: RoyColors.textSecondary)),
      ],
    );
  }
}