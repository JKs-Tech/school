import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentTransportRoutes extends StatefulWidget {
  const StudentTransportRoutes({super.key});

  @override
  _StudentTransportRoutesState createState() => _StudentTransportRoutesState();
}

class _StudentTransportRoutesState extends State<StudentTransportRoutes> {
  List<String> routeNameList = [];
  List<String> vehicleArray = [];
  bool isLoading = false, isDetailsLoading = false;
  String? _token, _id;
  int? _studentId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
    fetchDataFromApi();
  }

  Future<void> fetchDataFromApi() async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'student_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getTransportRouteUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      print('response = $response');

      if (response.statusCode == 200) {
        final result = response.body;
        print("Result: $result");
        List<dynamic> dataArray = jsonDecode(result);
        routeNameList.clear();
        vehicleArray.clear();
        if (dataArray.isNotEmpty) {
          for (final data in dataArray) {
            routeNameList.add(data['route_title']);
            vehicleArray.add(jsonEncode(data['vehicles']));
          }
        }
      }
    } catch (e) {
      print('student transport routes error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchVehicleDetails(
    BuildContext context,
    String vehicleId,
    String headerText,
  ) async {
    Map<String, String> params = {
      "vehicleId": vehicleId,
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    setState(() {
      isDetailsLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(
          await InfixApi.getApiUrl() + InfixApi.getTransportVehicleDetailsUrl(),
        ),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      print('body = $params');
      print('response = $response');
      print('response stues = ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> dataArray = jsonDecode(response.body);
        print('response jsonResult = $dataArray');
        final vehicleDetails = dataArray[0];
        await showVehicleDetails(headerText, vehicleDetails);
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Fetching data failed!')),
        // );
      }
    } catch (e) {
      print('fetch vehicle details error = ${e.toString()}');
    } finally {
      setState(() {
        isDetailsLoading = false;
      });
    }
  }

  Future<void> showVehicleDetails(
    String headerText,
    Map<String, dynamic> vehicleDetails,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            headerText,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height *
                    0.6, // Adjust height if needed
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (vehicleDetails.containsKey('vehicle_no') &&
                      vehicleDetails['vehicle_no'] != null)
                    buildDetailRow(
                      "Vehicle No: ",
                      vehicleDetails['vehicle_no'],
                    ),
                  if (vehicleDetails.containsKey('vehicle_model') &&
                      vehicleDetails['vehicle_model'] != null)
                    buildDetailRow(
                      "Vehicle Model: ",
                      vehicleDetails['vehicle_model'],
                    ),
                  if (vehicleDetails.containsKey('manufacture_year') &&
                      vehicleDetails['manufacture_year'] != null)
                    buildDetailRow(
                      "Made: ",
                      vehicleDetails['manufacture_year'],
                    ),
                  if (vehicleDetails.containsKey('driver_name') &&
                      vehicleDetails['driver_name'] != null)
                    buildDetailRow(
                      "Driver Name: ",
                      vehicleDetails['driver_name'],
                    ),
                  if (vehicleDetails.containsKey('driver_license') &&
                      vehicleDetails['driver_license'] != null)
                    buildDetailRow(
                      "Driver License: ",
                      vehicleDetails['driver_license'],
                    ),
                  if (vehicleDetails.containsKey('driver_contact') &&
                      vehicleDetails['driver_contact'] != null)
                    buildDetailRow(
                      "Driver Contact: ",
                      vehicleDetails['driver_contact'],
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Transport Route'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : routeNameList.isEmpty
                ? Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/no_data.png',
                        width: 200,
                        height: 200,
                      ),
                      Text('No Data Available'),
                    ],
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Stack(
                    children: [
                      ListView.builder(
                        itemCount: routeNameList.length,
                        itemBuilder: (context, position) {
                          return Column(
                            children: [
                              StudentTransportRouteAdapterWidget(
                                routeName: routeNameList[position],
                                vehicleWidgets: buildVehicleWidgets(
                                  context,
                                  vehicleArray[position],
                                ),
                              ),
                              SizedBox(height: 16.0),
                            ],
                          );
                        },
                      ),
                      isDetailsLoading
                          ? Center(child: CupertinoActivityIndicator())
                          : Container(),
                    ],
                  ),
                ),
      ),
    );
  }

  List<Widget> buildVehicleWidgets(BuildContext context, String vehicleData) {
    List<Widget> widgets = [];
    List<dynamic> dataArray = jsonDecode(vehicleData);

    for (final data in dataArray) {
      final vehicleNo = data['vehicle_no'];
      final isAssigned = data['assigned'] == "yes";

      widgets.add(
        vehicleItem(
          vehicleNo,
          isAssigned,
          () => fetchVehicleDetails(context, data['id'], vehicleNo),
        ),
      );
    }
    return widgets;
  }

  Widget vehicleItem(
    String vehicleNo,
    bool isAssigned,
    Function() onViewDetails,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Row(
        children: [
          Image.asset(
            'assets/images/ic_bus.png', // Replace with actual image path
            width: 25.0,
            height: 25.0,
          ),
          SizedBox(width: 10.0),
          Text(
            vehicleNo,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (isAssigned)
            Text("Assigned", style: TextStyle(color: Colors.blue)),
          Spacer(),
          ElevatedButton(
            onPressed: onViewDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Set button background color here
              foregroundColor: Colors.white, // Set text color here
            ),
            child: Text('View'),
          ),
        ],
      ),
    );
  }
}

class StudentTransportRouteAdapterWidget extends StatelessWidget {
  final String routeName;
  final List<Widget> vehicleWidgets;

  const StudentTransportRouteAdapterWidget({
    super.key,
    required this.routeName,
    required this.vehicleWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/ic_nav_transport.png', // Replace with actual image path
                  width: 25.0,
                  height: 25.0,
                ),
                SizedBox(width: 10.0),
                Text(
                  routeName,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Column(children: vehicleWidgets),
        ],
      ),
    );
  }
}
