import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/teachers/StudentTeacherNewAdapter.dart';
import 'package:infixedu/screens/student/teachers/Teacher.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentTeachersList extends StatefulWidget {
  const StudentTeachersList({super.key});

  @override
  _StudentTeachersListState createState() => _StudentTeachersListState();
}

class _StudentTeachersListState extends State<StudentTeachersList> {
  List<Teacher> teacherList = [];
  String? _token, _id, _role;
  bool isLoading = false;

  @override
  void initState() {
    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getStringValue('role').then((value) {
      _role = value;
    });
    Utils.getStringValue('id').then((idValue) {
      setState(() {
        _id = idValue;
        loadTeachers();
      });
    });
    super.initState();
  }

  void loadTeachers() async {
    try {
      setState(() {
        isLoading = true;
      });
      Map params = {
        'user_id': _id.toString(),
        'class_id': "",
        'section_id': "",
        'schoolId': await Utils.getStringValue('schoolId'),
      };
      var body = jsonEncode(params);
      final response = await http.post(
        Uri.parse(
          await InfixApi.getApiUrl() + InfixApi.getStudentTeacherListUrl(),
        ),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final dataObject = jsonData['result_list'];
        print('dataobject = $dataObject');
        print('jsonData = $jsonData');

        teacherList.clear();
        if (dataObject == null) {
          return;
        }
        dataObject?.forEach((key, value) {
          teacherList.add(
            Teacher(
              name: value['staff_name'] + ' ' + value['staff_surname'],
              contact: value['contact_no'],
              email: value['email'],
              isClassTeacher:
                  int.parse(value['class_teacher_id'].toString()) > 0,
              staffId: value['staff_id'],
              rating: double.parse(value['rate'].toString()),
            ),
          );
        });
      }
    } catch (e) {
      print('student teacher list error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateTeacherRating(String staffId, double newRating) {
    loadTeachers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomScreenAppBarWidget(title: 'Teachers'),
      body: SafeArea(
        child:
            isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CupertinoActivityIndicator(radius: 20),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Loading Teachers...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : teacherList.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school,
                          size: 80,
                          color: Colors.blue[300],
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'No Teachers Available',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Teachers will appear here once assigned',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          loadTeachers();
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: () async {
                    loadTeachers();
                  },
                  child: StudentTeacherNewAdapter(
                    teacherList: teacherList,
                    token: _token ?? '',
                    id: _id ?? '',
                    role: _role ?? '',
                    onRatingAdded: _updateTeacherRating,
                  ),
                ),
      ),
    );
  }
}
