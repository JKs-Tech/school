import 'Bus.dart';

class Driver {
  final String? driverId;
  final String? busId;
  final String? name;
  final String? channel;
  final String? lastLatitude;
  final String? lastLongitude;
  final String? telNumber;
  final String? verified;
  final String? active;
  final Bus? bus;

  Driver({
    this.driverId,
    this.busId,
    this.name,
    this.channel,
    this.lastLatitude,
    this.lastLongitude,
    this.telNumber,
    this.verified,
    this.active,
    this.bus,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driver_id'] ?? "",
      busId: json['bus_id'] ?? "",
      name: json['name'] ?? "",
      channel: json['channel'] ?? "",
      lastLatitude: json['last_latitude'] ?? "0",
      lastLongitude: json['last_longitude'] ?? "0",
      telNumber: json['tel_number'] ?? "",
      verified: json['verified'] ?? "",
      active: json['active'] ?? "",
      bus: json['bus'] != null ? Bus.fromJson(json['bus']) : null,
    );
  }
}
