class School {
  final String? id;
  final String? name;
  final String? email;
  final String? channel;
  final String? address;
  final String? latitude;
  final String? longitude;

  School({
    this.id,
    this.name,
    this.email,
    this.channel,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      channel: json['channel'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
