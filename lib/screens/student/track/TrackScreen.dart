import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/models/Parent.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:infixedu/config/app_config.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  _TrackScreenState createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  String? _token, _id;
  int? _studentId;
  bool isLoading = true, _serviceEnabled = false, isShowDialog = false;
  Parent? parent;
  List<LatLng> points = [
    LatLng(26.907524, 75.739639),
    LatLng(26.8669, 75.79735),
  ];
  LatLng startPoint = LatLng(26.907524, 75.739639),
      endPoint = LatLng(26.8669, 75.79735);
  PermissionStatus? _permissionGranted;
  Location location = Location();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  MapController mapController = MapController();
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
    _checkLocationServices();
  }

  Future<void> _fireStoreData() async {
    String formattedDate = DateFormat('MM-dd-yyyy').format(DateTime.now());
    final db = FirebaseFirestore.instance;
    final path =
        '/trackCollection/${parent?.school?.id}/drivers/${parent?.driver?.driverId}/date/$formattedDate';
    final docRef = db.doc(path);
    _subscription = docRef.snapshots().listen((event) {
      if (event.data() != null) {
        Map<String, dynamic> map = event.data() ?? {};
        List<dynamic> data = map['data'];
        points.clear();
        if (data.isNotEmpty) {
          startPoint = LatLng(
            data[0]['last_longitude'].toDouble(),
            data[0]['last_latitude'].toDouble(),
          );
          for (var item in data) {
            double lastLongitude = item['last_longitude'].toDouble();
            double speed = item['speed'].toDouble();
            double lastLatitude = item['last_latitude'].toDouble();
            print(
              'Last Longitude: $lastLongitude, Speed: $speed, Last Latitude: $lastLatitude',
            );
            points.add(LatLng(lastLatitude, lastLongitude));
          }
          if (isMapReady && points.isNotEmpty) {
            mapController.move(points.last, 15.0);
          }
        }
      }
      setState(() {
        isLoading = false;
      });
    }, onError: (error) => print("Listen failed: $error"));
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
    fetchDataFromApi();
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
        print('parentObject = $parentObject');
        print('params = $params');
        parent = Parent.fromJson(parentObject['parent']);
        print('parent = $parent');

        print(parent?.addressLatitude);
        print(parent?.addressLongitude);
        print(parent?.driver?.lastLatitude);
        print(parent?.driver?.lastLongitude);

        // check lat long should not be empty and null with and condition

        if (parent?.addressLatitude != null &&
            parent?.addressLongitude != null &&
            parent?.driver?.lastLatitude != null &&
            parent?.driver?.lastLongitude != null &&
            parent?.addressLatitude != "" &&
            parent?.addressLongitude != "" &&
            parent?.driver?.lastLatitude != "" &&
            parent?.driver?.lastLongitude != "") {
          endPoint = LatLng(
            double.parse(parent?.addressLatitude ?? "0"),
            double.parse(parent?.addressLongitude ?? "0"),
          );
          startPoint = LatLng(
            double.parse(parent?.driver?.lastLatitude ?? "0"),
            double.parse(parent?.driver?.lastLongitude ?? "0"),
          );
        }

        if (parent?.driver?.driverId?.isNotEmpty ?? false) {
          _fireStoreData();
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Something went wrong')));
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: $e')),
      // );
      setState(() {
        isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Track bus'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    // center: points.isNotEmpty ? points.last : startPoint,
                    // // Starting at the given point
                    // zoom: 15.0,
                    onMapReady: () {
                      isMapReady = true;
                      if (isMapReady && points.isNotEmpty) {
                        mapController.move(points.last, 15.0);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: startPoint, // Starting point marker
                          child: Icon(
                            Icons.school,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                        if (points
                            .isNotEmpty) // Show marker for last received point
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: points.last,
                            child: Icon(
                              Icons.bus_alert_sharp,
                              color: Colors.blue,
                              size: 40.0,
                            ),
                          ),
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: endPoint,
                          child: Icon(
                            Icons.home,
                            color: Colors.green,
                            size: 40.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
