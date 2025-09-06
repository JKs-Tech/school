import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/videoclass/StudentSubjectDetails.dart';
import 'package:infixedu/screens/student/videoclass/StudentVideoClassList.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:intl/intl.dart';

class StudentVideoClass extends StatefulWidget {
  const StudentVideoClass({super.key});

  @override
  _StudentVideoClassState createState() => _StudentVideoClassState();
}

class _StudentVideoClassState extends State<StudentVideoClass> {
  Map<String, List<StudentSubjectDetails>> subjectDataMapping = {};
  List<String> subjectNameList = [];
  String? _token, _id;
  int? _studentId;
  bool isLoading = false;
  DateTime? monday;

  @override
  void initState() {
    super.initState();
    monday = DateTime.now();
    while (monday?.weekday != DateTime.monday) {
      monday = monday?.subtract(Duration(days: 1));
    }

    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getIntValue('studentId').then((value) {
      _studentId = value;
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
        final result = response.body;
        processApiResponse(result);
      }
    } catch (e) {
      print('Video class error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void processApiResponse(String result) {
    setState(() {
      subjectDataMapping.clear();
      subjectNameList.clear();

      print('video class result = $result');
      final object = json.decode(result);
      print('video class object = $result');

      if (object['status'] == "200") {
        Map<String, dynamic> dataObject = object["timetable"];
        List<String> days = [
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
          "Friday",
          "Saturday",
          "Sunday",
        ];
        print('video class dataObject = $dataObject');
        DateFormat df = DateFormat("MM/dd/yyyy");
        List<String> dates = [
          df.format(monday ?? DateTime.now()),
          df.format(monday!.add(Duration(days: 1))),
          df.format(monday!.add(Duration(days: 2))),
          df.format(monday!.add(Duration(days: 3))),
          df.format(monday!.add(Duration(days: 4))),
          df.format(monday!.add(Duration(days: 5))),
          df.format(monday!.add(Duration(days: 6))),
        ];
        for (String day in days) {
          List<dynamic> dayArray = dataObject[day];
          print('video class day = $day');
          print('video class dayArray = $dayArray');
          if (dayArray.isNotEmpty) {
            for (int i = 0; i < dayArray.length; i++) {
              Map<String, dynamic> subjectObject = dayArray[i];
              String subjectName = subjectObject["subject_name"];
              String subjectCode = subjectObject["code"] ?? "";
              String subjectFullName =
                  subjectCode.isEmpty
                      ? subjectName
                      : "$subjectName ($subjectCode)";
              String timeFrom = subjectObject["time_from"] ?? "";
              String timeTo = subjectObject["time_to"] ?? "";
              String roomNumber = subjectObject["room_no"] ?? "";
              String subjectId = subjectObject["subject_group_subject_id"];
              String sectionId =
                  subjectObject["subject_group_class_sections_id"];

              if (timeFrom.isEmpty) {
                timeFrom = "Not Scheduled";
                timeTo = "Not Scheduled";
              } else {
                timeFrom += " - $timeTo";
              }

              if (!subjectNameList.contains(subjectFullName)) {
                subjectNameList.add(subjectFullName);
              }
              StudentSubjectDetails studentSubjectDetails =
                  StudentSubjectDetails(
                    subjectName: subjectFullName,
                    fromTime: timeFrom,
                    toTime: timeTo,
                    date: dates[i],
                    time: timeFrom,
                    roomNo: roomNumber,
                    subjectId: subjectId,
                    sectionId: sectionId,
                  );
              subjectDataMapping
                  .putIfAbsent(subjectFullName, () => [])
                  .add(studentSubjectDetails);
              print('video class subjectNameList = $subjectNameList');
              print('video class subjectDataMapping = $subjectDataMapping');
            }
          } else {
            // Handle the case where the dayArray is empty
          }
        }
      } else {
        print("API request error: ${object["errorMsg"]}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Video class'),
      body: SafeArea(
        child:
            isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(),
                      SizedBox(height: 10),
                      Text("Loading classes..."),
                    ],
                  ),
                )
                : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (subjectNameList.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/no_data.png',
                                  width: 200,
                                  height: 200,
                                ),
                                Text(
                                  'No Data Available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: subjectNameList.length,
                            itemBuilder: (BuildContext context, int index) {
                              String subjectName = subjectNameList[index];
                              return Card(
                                elevation: 5,
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 15,
                                  ),
                                  title: Text(
                                    subjectName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.blueGrey,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => StudentVideoClassList(
                                              subjectName: subjectName,
                                              studentSubjectsArrayList:
                                                  subjectDataMapping[subjectName] ??
                                                  [],
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
      ),
    );
  }
}
