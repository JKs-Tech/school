import 'Driver.dart';
import 'School.dart';
import 'Leave.dart';
class Parent {
  final String? name;
  final String? addressLatitude;
  final String? addressLongitude;
  final String? telNumber;
  final String? countryCode;
  final String? zoneAlertDistance;
  final String? arrivedSchool;
  final String? leftSchool;
  final String? arrivedHome;
  final String? leftHome;
  final Driver? driver;
  final School? school;
  final Leave? leave;

  Parent({
    this.name,
    this.addressLatitude,
    this.addressLongitude,
    this.telNumber,
    this.countryCode,
    this.zoneAlertDistance,
    this.arrivedSchool,
    this.leftSchool,
    this.arrivedHome,
    this.leftHome,
    this.driver,
    this.school,
    this.leave
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      name: json['name'],
      addressLatitude: json['address_latitude'],
      addressLongitude: json['address_longitude'],
      telNumber: json['tel_number'],
      countryCode: json['country_code'],
      zoneAlertDistance: json['zone_alert_distance'] == "0" ? "Off": '${json['zone_alert_distance']} meter',
      arrivedSchool: json['arrived_school'],
      leftSchool: json['left_school'],
      arrivedHome: json['arrived_home'],
      leftHome: json['left_home'],
      driver: Driver.fromJson(json['driver']),
      school: School.fromJson(json['school']),
      leave: Leave.fromJson(json['leave'])
    );
  }
}