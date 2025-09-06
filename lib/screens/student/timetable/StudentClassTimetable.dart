import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/timetable/DayData.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentClassTimetable extends StatefulWidget {
  const StudentClassTimetable({super.key});

  @override
  _StudentClassTimetableState createState() => _StudentClassTimetableState();
}

class _StudentClassTimetableState extends State<StudentClassTimetable> {
  Map<String, String> params = {};
  Map<String, String> headers = {};

  List<DayData> daysData = [];

  String? _token, _id;
  int? _studentId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getIntValue('studentId').then((value) {
      _studentId = value;
    });
    Utils.getStringValue('id').then((idValue) {
      setState(() {
        _id = idValue;
        fetchData();
      });
    });
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'student_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getClassScheduleUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        daysData = [
          DayData.fromJSON("Monday", data['timetable']['Monday']),
          DayData.fromJSON("Tuesday", data['timetable']['Tuesday']),
          DayData.fromJSON("Wednesday", data['timetable']['Wednesday']),
          DayData.fromJSON("Thursday", data['timetable']['Thursday']),
          DayData.fromJSON("Friday", data['timetable']['Friday']),
          DayData.fromJSON("Saturday", data['timetable']['Saturday']),
          DayData.fromJSON("Sunday", data['timetable']['Sunday']),
        ];
      }
    } catch (e) {
      print('student class timetable error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Time table'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : daysData.isEmpty
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
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children:
                          daysData.map((dayData) {
                            return DayCard(dayData: dayData);
                          }).toList(),
                    ),
                  ),
                ),
      ),
    );
  }
}

class DayCard extends StatelessWidget {
  final DayData dayData;

  const DayCard({super.key, required this.dayData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.0),
            child: Text(
              dayData.name,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: dayData.sessions.length,
            itemBuilder: (context, index) {
              final session = dayData.sessions[index];
              return ListTile(
                title: Text(session.subject),
                subtitle: Text(session.time),
                trailing: Text('Room No: ${session.roomNo}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
