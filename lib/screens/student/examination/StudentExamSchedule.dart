import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentExamSchedule extends StatefulWidget {
  final String examGroupId;

  const StudentExamSchedule({super.key, required this.examGroupId});

  @override
  _StudentExamScheduleState createState() => _StudentExamScheduleState();
}

class _StudentExamScheduleState extends State<StudentExamSchedule> {
  List<String> subjectList = [];
  List<String> dateList = [];
  List<String> timeList = [];
  List<String> creditHoursList = [];
  List<String> roomList = [];
  List<String> durationList = [];
  List<String> maxMarksList = [];
  List<String> minMarksList = [];
  String _token = '', _id = '';
  bool isLoading = false;

  @override
  void initState() {
    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getStringValue('id').then((idValue) {
      setState(() {
        _id = idValue;
        getDataFromApi(widget.examGroupId);
      });
    });
    super.initState();
  }

  Future<void> getDataFromApi(String examGroupId) async {
    setState(() {
      isLoading = true;
    });
    final Map params = {
      "exam_group_class_batch_exam_id": examGroupId,
      "schoolId": await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getExamScheduleUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataArray = responseData["exam_subjects"];

        setState(() {
          subjectList.clear();
          dateList.clear();
          timeList.clear();
          roomList.clear();
          durationList.clear();
          maxMarksList.clear();
          minMarksList.clear();

          for (int i = 0; i < dataArray.length; i++) {
            final Map<String, dynamic> dataObject = dataArray[i];
            subjectList.add(
              "${dataObject["subject_name"]} (${dataObject["subject_code"]})",
            );
            dateList.add(
              Utils.parseDate(
                "yyyy-MM-dd",
                "dd/MM/yyyy",
                dataObject["date_from"],
              ),
            );
            // timeList.add(dataObject["time_from"]);
            // roomList.add(dataObject["room_no"]);
            // creditHoursList.add(dataObject["credit_hours"]);
            // durationList.add(dataObject["duration"]);
            // maxMarksList.add(dataObject["max_marks"]);
            // minMarksList.add(dataObject["min_marks"]);

            if (dataObject["time_from"] != null &&
                dataObject["time_to"] != null &&
                dataObject["room_no"] != null &&
                dataObject["credit_hours"] != null &&
                dataObject["duration"] != null &&
                dataObject["max_marks"] != null &&
                dataObject["min_marks"] != null) {
              timeList.add(dataObject["time_from"]);
              roomList.add(dataObject["room_no"]);
              creditHoursList.add(dataObject["credit_hours"]);
              durationList.add(dataObject["duration"]);
              maxMarksList.add(dataObject["max_marks"]);
              minMarksList.add(dataObject["min_marks"]);
            } else {
              Fluttertoast.showToast(
                msg: "Failed to load data",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            }
          }
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data')));
      }
    } catch (e) {
      print('student exam schedule error  = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Examination Schedule'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ListView.builder(
                    itemCount: subjectList.length,
                    itemBuilder: (context, index) {
                      return StudentExamScheduleCard(
                        subject: subjectList[index],
                        date: dateList[index],
                        time: timeList[index],
                        room: roomList[index],
                        duration: durationList[index],
                        maxMarks: maxMarksList[index],
                        minMarks: minMarksList[index],
                        creditHours: creditHoursList[index],
                      );
                    },
                  ),
                ),
      ),
    );
  }
}

class StudentExamScheduleCard extends StatelessWidget {
  final String subject;
  final String date;
  final String time;
  final String room;
  final String duration;
  final String maxMarks;
  final String minMarks;
  final String creditHours;

  const StudentExamScheduleCard({
    super.key,
    required this.subject,
    required this.date,
    required this.time,
    required this.room,
    required this.duration,
    required this.maxMarks,
    required this.minMarks,
    required this.creditHours,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  "assets/images/ic_open_book.png",
                  width: 20,
                  height: 20,
                ),
                SizedBox(width: 10),
                Text(
                  subject,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/ic_calender.png",
                      width: 15,
                      height: 15,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(fontSize: 10, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(
                      "assets/images/ic_room.png",
                      width: 15,
                      height: 15,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Room No",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          (room.isEmpty) ? 'N/A' : room,
                          style: TextStyle(fontSize: 10, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(
                      "assets/images/schedule.png",
                      width: 15,
                      height: 15,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Start Time",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(fontSize: 10, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/schedule.png",
                      width: 15,
                      height: 15,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Duration",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          (duration.isEmpty) ? 'N/A' : duration,
                          style: TextStyle(fontSize: 10, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Max Marks",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      maxMarks,
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Min Marks",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      minMarks,
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Credit Hours",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      creditHours,
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
