class RideDetailModel {
  final int id;
  final String originCity;
  final String destinationCity;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final DateTime departureAt;
  final int availableSeats;
  final double totalCost;
  final double distanceKm;
  final double costPerPassenger;
  final String status;
  final RideDriver driver;
  final List<RideRequest> rideRequests;

  const RideDetailModel({
    required this.id,
    required this.originCity,
    required this.destinationCity,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.departureAt,
    required this.availableSeats,
    required this.totalCost,
    required this.distanceKm,
    required this.costPerPassenger,
    required this.status,
    required this.driver,
    required this.rideRequests,
  });

  factory RideDetailModel.fromJson(Map<String, dynamic> json) {
    final originParts = (json['origin_lat_lng'] as String).split(',');
    final destParts = (json['destination_lat_lng'] as String).split(',');

    return RideDetailModel(
      id: json['id'],
      originCity: json['origin_city'] ?? '',
      destinationCity: json['destination_city'] ?? '',
      originLat: double.tryParse(originParts[0]) ?? 0,
      originLng: double.tryParse(originParts[1]) ?? 0,
      destinationLat: double.tryParse(destParts[0]) ?? 0,
      destinationLng: double.tryParse(destParts[1]) ?? 0,
      departureAt: DateTime.tryParse(json['departure_at'] ?? '') ?? DateTime.now(),
      availableSeats: json['avaliable_seats'] ?? 0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0,
      distanceKm: double.tryParse(json['distance_km']?.toString() ?? '0') ?? 0,
      costPerPassenger: (json['cost_per_passenger'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? '',
      driver: RideDriver.fromJson(json['driver']),
      rideRequests: (json['ride_requests'] as List? ?? [])
          .map((r) => RideRequest.fromJson(r))
          .toList(),
    );
  }
}

class RideDriver {
  final int id;
  final String name;
  final String? photoUrl;
  final RideVehicle vehicle;

  const RideDriver({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.vehicle,
  });

  factory RideDriver.fromJson(Map<String, dynamic> json) => RideDriver(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        photoUrl: json['photo_url'],
        vehicle: RideVehicle.fromJson(json['vehicle'] ?? {}),
      );

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

class RideVehicle {
  final int id;
  final String plate;
  final String model;
  final String year;
  final String color;

  const RideVehicle({
    required this.id,
    required this.plate,
    required this.model,
    required this.year,
    required this.color,
  });

  factory RideVehicle.fromJson(Map<String, dynamic> json) => RideVehicle(
        id: json['id'] ?? 0,
        plate: json['plate'] ?? '',
        model: json['model'] ?? '',
        year: json['year'] ?? '',
        color: json['color'] ?? '',
      );
}

class RideRequest {
  final int id;
  final int passengerId;
  final int rideId;
  final String status;
  final double calculatedPrice;
  final RidePassenger passenger;

  const RideRequest({
    required this.id,
    required this.passengerId,
    required this.rideId,
    required this.status,
    required this.calculatedPrice,
    required this.passenger,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) => RideRequest(
        id: json['id'],
        passengerId: json['passenger_id'],
        rideId: json['ride_id'],
        status: json['status'],
        calculatedPrice: double.parse(json['calculated_price'].toString()),
        passenger: RidePassenger.fromJson(json['passenger']),
      );
}

class RidePassenger {
  final int id;
  final String name;
  final String? photoUrl;

  const RidePassenger({
    required this.id,
    required this.name,
    this.photoUrl,
  });

  factory RidePassenger.fromJson(Map<String, dynamic> json) => RidePassenger(
        id: json['id'],
        name: json['name'],
        photoUrl: json['photo_url'],
      );

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}