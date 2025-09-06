import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/examination/StudentExamResult.dart';
import 'package:infixedu/screens/student/examination/StudentExamSchedule.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

// ignore: must_be_immutable
class StudentExaminationList extends StatefulWidget {
  bool isBackIconVisible;

  StudentExaminationList({super.key, required this.isBackIconVisible});

  @override
  _StudentExaminationListState createState() => _StudentExaminationListState();
}

class _StudentExaminationListState extends State<StudentExaminationList> {
  List<String> examList = [];
  List<String> examGroupList = [];
  List<String> publishResultList = [];
  List<String> idList = [];
  String _token = '', _id = '';
  int _studentId = 0;
  bool isLoading = false;

  @override
  void initState() {
    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getIntValue('studentId').then((value) {
      _studentId = value;
    });
    Utils.getStringValue('id').then((idValue) {
      setState(() {
        _id = idValue;
        loadData();
      });
    });
    super.initState();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'student_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getExamListUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> dataArray = data["examSchedule"];

        setState(() {
          examList.clear();
          publishResultList.clear();
          examGroupList.clear();
          idList.clear();

          for (int i = 0; i < dataArray.length; i++) {
            examList.add(dataArray[i]["exam"]);
            publishResultList.add(dataArray[i]["result_publish"].toString());
            examGroupList.add(dataArray[i]["exam_group_class_batch_exam_id"]);
            idList.add(dataArray[i]["id"]);
          }
        });
      } else {}
    } catch (e) {
      print('student examination error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(
        title: 'Examination',
        isBackIconVisible: widget.isBackIconVisible,
      ),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : examList.isEmpty
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
                  child: ListView.builder(
                    itemCount: examList.length,
                    itemBuilder: (context, index) {
                      return StudentExamListAdapterItem(
                        examName: examList[index],
                        publishResult: publishResultList[index],
                        onExamScheduleClicked: () {
                          _onExamScheduleClicked(context, index);
                        },
                        onExamResultClicked: () {
                          _onExamResultClicked(context, index);
                        },
                      );
                    },
                  ),
                ),
      ),
    );
  }

  void _onExamScheduleClicked(BuildContext context, int index) {
    String examGroupId = examGroupList[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentExamSchedule(examGroupId: examGroupId),
      ),
    );
  }

  void _onExamResultClicked(BuildContext context, int index) {
    String examGroupId = examGroupList[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentExamResult(examGroupId: examGroupId),
      ),
    );
  }
}

class StudentExamListAdapterItem extends StatelessWidget {
  final String examName;
  final String publishResult;
  final Function() onExamScheduleClicked;
  final Function() onExamResultClicked;

  const StudentExamListAdapterItem({
    super.key,
    required this.examName,
    required this.publishResult,
    required this.onExamScheduleClicked,
    required this.onExamResultClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/ic_nav_reportcard.png', // Replace with your subject icon asset
                  width: 25,
                  height: 25,
                ), // Replace with your icon widget
                SizedBox(width: 10),
                Text(
                  examName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Set your text color here
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: publishResult != "0",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: onExamResultClicked,
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/baseline_receipt.png', // Replace with your subject icon asset
                              width: 15,
                              height: 15,
                            ), // Replace with your icon widget
                            SizedBox(width: 5),
                            Text(
                              "Exam Result",
                              style: TextStyle(
                                color:
                                    Colors
                                        .blue, // Set your hyperlink color here
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onExamScheduleClicked,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/schedule.png', // Replace with your subject icon asset
                        width: 15,
                        height: 15,
                      ), // Replace with your icon widget
                      SizedBox(width: 5),
                      Text(
                        "Exam Schedule",
                        style: TextStyle(
                          color: Colors.blue, // Set your hyperlink color here
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
