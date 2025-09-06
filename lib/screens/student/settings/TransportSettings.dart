import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/models/Parent.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:infixedu/config/app_config.dart';

class TransportSettings extends StatefulWidget {
  const TransportSettings({super.key});

  @override
  _TransportSettingsState createState() => _TransportSettingsState();
}

class _TransportSettingsState extends State<TransportSettings> {
  Parent? parent;
  bool isLoading = false,
      isStateChange = false,
      arrivedSchool = false,
      leftSchool = false,
      arrivedHome = false,
      leftHome = false;
  String _token = "",
      _id = "",
      absentTillDate = "",
      selectedDistance = "0",
      selectedAddressLatitude = "",
      selectedAddressLongitude = "";
  int _studentId = 0;
  Location location = Location();
  bool _serviceEnabled = false, isShowDialog = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData _locationData = LocationData.fromMap({
    'latitude': 0.0,
    'longitude': 0.0,
  });
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
    arrivedHome = await Utils.getBooleanValueWithoutDefault('arrivedHome');
    leftHome = await Utils.getBooleanValueWithoutDefault('leftHome');
    arrivedSchool = await Utils.getBooleanValueWithoutDefault('arrivedSchool');
    leftSchool = await Utils.getBooleanValueWithoutDefault('leftSchool');
    fetchDataFromApi();
  }

  Future<void> _checkLocationServices() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      if (isShowDialog == false) {
        showPermissionPopup(context);
        return;
      } else {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
    }
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _locationSubscription = location.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      _locationData = currentLocation;
      if (_locationData.latitude != null &&
          _locationData.latitude! > 0 &&
          _locationData.longitude != null &&
          _locationData.longitude! > 0) {
        _locationSubscription?.cancel();
        updatePositionFromApi(
          _locationData.latitude!,
          _locationData.longitude!,
        );
      }
    });
  }

  void showPermissionPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Data Collection'),
          content: Text(
            '${AppConfig.appName} collects location data to enable bus tracking feature even when the app is closed or not in use. Do you accept the collection of this data?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Deny'),
              onPressed: () {
                // Handle user's denial of location data collection here
                Navigator.of(context).pop(); // Close the dialog
                isShowDialog = true;
              },
            ),
            TextButton(
              child: Text('Accept'),
              onPressed: () {
                // Handle user's acceptance of location data collection here
                Navigator.of(context).pop(); // Close the dialog
                isShowDialog = true;
                _checkLocationServices();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchDataFromApi() async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'user_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(
          await InfixApi.getApiUrl() + InfixApi.getVerifyParentTelNumberUrl(),
        ),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> parentObject = jsonDecode(response.body);
        print('parentobject = $parentObject');
        parent = Parent.fromJson(parentObject['parent']);
        print('parent = $parent');
        print('parent name = ${parent?.name}');
        if (parent?.leave?.isBlank == false) {
          absentTillDate = parent!.leave!.toDate ?? "";
        }
        selectedDistance = parent?.zoneAlertDistance ?? "0";
        selectedAddressLatitude = parent?.addressLatitude ?? "";
        selectedAddressLongitude = parent?.addressLongitude ?? "";
        if (double.parse(selectedAddressLatitude) > 0 &&
            double.parse(selectedAddressLatitude) > 0) {
          setDefaultNotificationValue();
        }
        print('parent = $parent');
      }
    } catch (e) {
      print('student transport settings error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void changeAbsentStatus(bool isAbsent) {
    String strDate = "";
    if (isAbsent) {
      DateTime tomorrowDate = DateTime.now().add(Duration(days: 1));
      strDate = DateFormat('yyyy-MM-dd').format(tomorrowDate);
    }
    updateAbsentApi(strDate);
  }

  Future<void> updateAbsentApi(String absentDate) async {
    setState(() {
      isStateChange = true;
    });
    Map params = {
      'user_id': _studentId.toString(),
      "tomorrow_date": absentDate,
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(
          await InfixApi.getApiUrl() + InfixApi.getUpdateChildAbsentUrl(),
        ),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        absentTillDate = absentDate;
      }
    } catch (e) {
      print('update absent error = ${e.toString()}');
    } finally {
      setState(() {
        isStateChange = false;
      });
    }
  }

  Future<void> setZoneAlertDistanceFromApi(int distance) async {
    setState(() {
      isStateChange = true;
    });
    Map params = {
      'user_id': _studentId.toString(),
      "zone_alert_distance": distance,
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(
          await InfixApi.getApiUrl() + InfixApi.setZoneAlertDistanceUrl(),
        ),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        if (distance == 0) {
          selectedDistance = "Off";
        } else {
          selectedDistance = '$distance meter';
        }
      }
    } catch (e) {
      print('send zone distance = ${e.toString()}');
    } finally {
      setState(() {
        isStateChange = false;
      });
    }
  }

  Future<void> updatePositionFromApi(
    double addressLatitude,
    double addressLongitude,
  ) async {
    setState(() {
      isStateChange = true;
    });
    Map params = {
      'user_id': _studentId.toString(),
      'address_latitude': addressLatitude,
      'address_longitude': addressLongitude,
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.updatePositionUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        selectedAddressLatitude = addressLatitude.toString();
        selectedAddressLongitude = addressLongitude.toString();
        setDefaultNotificationValue();
      }
    } catch (e) {
      print('update position error = ${e.toString()}');
    } finally {
      _locationSubscription?.cancel();
      setState(() {
        isStateChange = false;
      });
    }
  }

  void setDefaultNotificationValue() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Settings'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : Stack(
                  children: [
                    ListView(
                      children: [
                        ListTile(
                          title: Text(
                            'Absent Setting',
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                        ),
                        absentTillDate == null
                            ? ListTile(
                              title: Text(
                                '${parent?.name} as absent',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              trailing: Switch(
                                value: false,
                                inactiveTrackColor: Colors.white,
                                activeColor: Colors.blue,
                                onChanged: (value) {
                                  if (!isStateChange) {
                                    changeAbsentStatus(value);
                                  }
                                },
                              ),
                            )
                            : ListTile(
                              title: Text(
                                '${parent?.name} as absent',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                'absent until $absentTillDate',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              trailing: Switch(
                                value: true,
                                inactiveTrackColor: Colors.white,
                                activeColor: Colors.blue,
                                onChanged: (value) {
                                  if (!isStateChange) {
                                    changeAbsentStatus(value);
                                  }
                                },
                              ),
                            ),
                        Divider(),
                        ListTile(
                          title: Text(
                            'Location Setting',
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Set Pickup Drop-off Location',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          subtitle: Text(
                            (selectedAddressLatitude.isNotEmpty &&
                                    selectedAddressLongitude.isNotEmpty)
                                ? ("$selectedAddressLatitude, $selectedAddressLongitude")
                                : 'Set location to receive notification',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          onTap: () {
                            if (!isStateChange) {
                              _checkLocationServices();
                            }
                          },
                        ),
                        Divider(),
                        ListTile(
                          title: Text(
                            "Notification Settings",
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                        ),
                        Opacity(
                          opacity: arrivedSchool == null ? 0.5 : 1.0,
                          child: SwitchListTile(
                            title: Text(
                              'When bus arrived at school',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: arrivedSchool ?? false,
                            activeColor: Colors.blue,
                            inactiveTrackColor: Colors.white,
                            onChanged: (value) {
                              setState(() {
                                arrivedSchool = value;
                              });
                              Utils.saveBooleanValue('arrivedSchool', value);
                            },
                          ),
                        ),
                        Opacity(
                          opacity: leftSchool == null ? 0.5 : 1.0,
                          child: SwitchListTile(
                            title: Text(
                              'When bus left school',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: leftSchool ?? false,
                            activeColor: Colors.blue,
                            inactiveTrackColor: Colors.white,
                            onChanged: (value) {
                              setState(() {
                                leftSchool = value;
                              });
                              Utils.saveBooleanValue('leftSchool', value);
                            },
                          ),
                        ),
                        Opacity(
                          opacity: arrivedHome == null ? 0.5 : 1.0,
                          child: SwitchListTile(
                            title: Text(
                              'When bus arrived at your location',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: arrivedHome,
                            inactiveTrackColor: Colors.white,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              setState(() {
                                arrivedHome = value;
                              });
                              Utils.saveBooleanValue('arrivedHome', value);
                            },
                          ),
                        ),
                        Opacity(
                          opacity: leftHome == null ? 0.5 : 1.0,
                          child: SwitchListTile(
                            title: Text(
                              'When bus left your location',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: leftHome,
                            activeColor: Colors.blue,
                            inactiveTrackColor: Colors.white,
                            onChanged: (value) {
                              setState(() {
                                leftHome = value;
                              });
                              Utils.saveBooleanValue('leftHome', value);
                            },
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            if (!isStateChange) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DistanceDialog((selectedDistance) {
                                    setZoneAlertDistanceFromApi(
                                      selectedDistance,
                                    );
                                    Navigator.pop(context); // Close the dialog
                                  });
                                },
                              );
                            }
                          },
                          title: Text(
                            'When Bus is Near My Home By',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          subtitle: Text(
                            selectedDistance,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.0),
                      ],
                    ),
                    isStateChange
                        ? Center(child: CupertinoActivityIndicator())
                        : Container(),
                  ],
                ),
      ),
    );
  }
}

class DistanceDialog extends StatelessWidget {
  final Function(int) onDistanceSelect;
  final List<int> distanceOptions = [0, 500, 1000, 1500, 2000];

  DistanceDialog(this.onDistanceSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Distance'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: distanceOptions.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(
                index == 0
                    ? 'Off'
                    : '${distanceOptions[index].toString()} meter',
              ),
              onTap: () {
                onDistanceSelect(distanceOptions[index]); // Close the dialog
              },
            );
          },
        ),
      ),
    );
  }
}
