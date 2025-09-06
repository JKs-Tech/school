class Bus {
  final String? busId;
  final String? license;
  final String? active;

  Bus({this.busId, this.license, this.active});

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      busId: json['bus_id'],
      license: json['license'],
      active: json['active'],
    );
  }
}
