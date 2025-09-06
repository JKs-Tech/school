import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentHostel extends StatefulWidget {
  const StudentHostel({super.key});

  @override
  _StudentHostelState createState() => _StudentHostelState();
}

class _StudentHostelState extends State<StudentHostel> {
  List<String> hostelIdList = [];
  List<String> hostelNameList = [];
  String _token = '', _id = '', _currency = '';
  int _studentId = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getIntValue('studentId').then((value) {
      _studentId = value;
    });
    Utils.getIntValue('studentId').then((value) {
      _studentId = value;
    });
    Utils.getStringValue('currency').then((value) {
      _currency = value;
    });
    Utils.getStringValue('id').then((idValue) {
      setState(() {
        _id = idValue;
        getDataFromApi();
      });
    });
  }

  Future<void> getDataFromApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      var request = http.Request(
        'GET',
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getHostelListUrl()),
      );
      request.body = json.encode({
        'schoolId': await Utils.getStringValue('schoolId'),
      });
      request.headers.addAll(
        Utils.setHeaderNew(_token.toString(), _id.toString()),
      );
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(
          await response.stream.bytesToString(),
        );
        print('hostel result = $result');
        int success = result["success"];
        print('hostel success = $success');
        if (success == 1) {
          List<dynamic> dataArray = result["data"];
          print('hostel dataArray = $dataArray');
          for (var data in dataArray) {
            hostelIdList.add(data["id"]);
            hostelNameList.add(data["hostel_name"]);
          }
          print('hostel hostelIdList = $hostelIdList');
          print('hostel hostelNameList = $hostelNameList');
          setState(() {});
        }
      }
    } catch (e) {
      print('student hotel error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Hostels'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : hostelIdList.isEmpty
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
                  child: StudentHostelListView(
                    context,
                    hostelIdList,
                    hostelNameList,
                    _studentId,
                    _token,
                    _id,
                    _currency,
                  ),
                ),
      ),
    );
  }
}

class StudentHostelListView extends StatelessWidget {
  final BuildContext context;
  final List<String> hostelIdList;
  final List<String> hostelNameList;
  final int _studentId;
  final String _token, _id, _currency;

  const StudentHostelListView(
    this.context,
    this.hostelIdList,
    this.hostelNameList,
    this._studentId,
    this._token,
    this._id,
    this._currency, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: hostelIdList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showHostelDetails(hostelIdList[index], hostelNameList[index]);
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/ic_nav_hostel.png', // Replace with the actual image path
                    width: 20,
                    height: 30,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hostelNameList[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showHostelDetails(
                        hostelIdList[index],
                        hostelNameList[index],
                      );
                    },
                    child: Container(
                      width: 70,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/ic_view.png', // Replace with the actual image path
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'View',
                            style: TextStyle(color: Colors.blue, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showHostelDetails(String hostelId, String hostelName) async {
    Map<String, String> params = {
      'hostelId': hostelId,
      'student_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getHostelDetailsUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        int success = result["success"];
        if (success == 1) {
          String currency = _currency;
          List<dynamic> dataArray = result["data"];
          List<String> roomTypeList = [];
          List<String> roomNumberList = [];
          List<String> roomCostList = [];
          List<String> noOfBedlist = [];
          List<String> studentIdlist = [];

          for (var data in dataArray) {
            roomTypeList.add(data["room_type"]);
            roomNumberList.add(data["room_no"]);
            roomCostList.add(currency + data["cost_per_bed"]);
            noOfBedlist.add(data["no_of_bed"]);
            studentIdlist.add(data["student_id"]);
          }
          showHostelDetailsDialog(
            context,
            hostelName,
            roomTypeList,
            roomNumberList,
            roomCostList,
            noOfBedlist,
            studentIdlist,
          );
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text(result["errorMsg"])),
          // );
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Something went wrong')),
        // );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: $e')),
      // );
    }
  }

  void showHostelDetailsDialog(
    BuildContext context,
    String hostelName,
    List<String> roomTypeList,
    List<String> roomNumberList,
    List<String> roomCostList,
    List<String> noOfBedlist,
    List<String> studentIdlist,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            hostelName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                roomTypeList.length,
                (index) => ListTile(
                  title: Text(roomTypeList[index]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room Number: ${roomNumberList[index]}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Cost per Bed: ${roomCostList[index]}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Number of Beds: ${noOfBedlist[index]}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
