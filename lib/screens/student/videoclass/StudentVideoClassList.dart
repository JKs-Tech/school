import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/videoclass/StudentSubjectDetails.dart';
import 'package:infixedu/screens/student/videoclass/StudentVideoClassDetails.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentVideoClassList extends StatefulWidget {
  final List<StudentSubjectDetails> studentSubjectsArrayList;
  final String subjectName;

  const StudentVideoClassList({
    super.key,
    required this.subjectName,
    required this.studentSubjectsArrayList,
  });

  @override
  _StudentVideoClassListState createState() => _StudentVideoClassListState();
}

class _StudentVideoClassListState extends State<StudentVideoClassList> {
  List<StudentSubjectDetails> newStudentSubject = [];
  String subjectId = '';
  String sectionId = '';
  StudentSubjectDetails? studentSubjectouter;
  String? _token, _id;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.studentSubjectsArrayList.isNotEmpty) {
      studentSubjectouter = widget.studentSubjectsArrayList[0];
      subjectId = studentSubjectouter?.subjectId ?? '';
      sectionId = studentSubjectouter?.sectionId ?? '';
    }
    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getStringValue('id').then((idValue) {
      setState(() {
        _id = idValue;
        loadData(studentSubjectouter!, subjectId, sectionId);
      });
    });
  }

  void loadData(
    StudentSubjectDetails studentSubject,
    String subjectId,
    String sectionId,
  ) async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> params = {
      'subject_group_subject_id': subjectId,
      'subject_group_class_sections_id': sectionId,
      'time_from': '1:53 AM',
      'time_to': '2:53 AM',
      'date': studentSubject.date ?? '',
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    print('video class details body = ${json.encode(params)}');
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getSyllabusUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      print('video class details response = $response');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('video class details data = $data');
        if (data['data'] != null) {
          List<StudentSubjectDetails> subjects = [];
          for (var item in data['data']) {
            String subjectName =
                item['code'].isEmpty
                    ? item['name']
                    : '${item['name']} (${item['code']})';
            String fromTime =
                item['time_from'].isEmpty
                    ? 'Not Scheduled'
                    : '${item['time_from']}';

            StudentSubjectDetails studentSubjects = StudentSubjectDetails(
              subjectName: subjectName,
              fromTime: fromTime,
              toTime: item['time_to'],
              date: item['date'],
              time:
                  'Not Scheduled' == fromTime
                      ? fromTime
                      : '$fromTime-${item['time_to']}',
              roomNo: item['topic_id'],
              subjectId: subjectId,
              sectionId: sectionId,
            );

            subjects.add(studentSubjects);
          }
          print('video class details subjects = $subjects');
          setState(() {
            newStudentSubject = subjects;
          });
        }
      }
    } catch (e) {
      print('student video list error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: widget.subjectName),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : newStudentSubject.isEmpty
                ? Center(
                  child: Container(
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
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Time',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Syllabus',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (newStudentSubject.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            itemCount: newStudentSubject.length,
                            itemBuilder: (context, index) {
                              StudentSubjectDetails subject =
                                  newStudentSubject[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => StudentVideoClassDetails(
                                            studentSubjectDetails: subject,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 5,
                                  ),
                                  child: Card(
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              subject.date ?? "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(fontSize: 14),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              subject.time ?? "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(fontSize: 14),
                                            ),
                                          ),
                                          Expanded(
                                            child: Image.asset(
                                              "assets/images/ic_nav_subject.png",
                                              width: 25,
                                              height: 25,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
