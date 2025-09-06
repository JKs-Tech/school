import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/studentSyllabus/StudentSyllabusLesson.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentSyllabusStatus extends StatefulWidget {
  const StudentSyllabusStatus({super.key});

  @override
  _StudentSyllabusStatusState createState() => _StudentSyllabusStatusState();
}

class _StudentSyllabusStatusState extends State<StudentSyllabusStatus> {
  List<String> subjectNameList = [];
  List<String> totalCompleteList = [];
  List<String> idList = [];
  List<String> subjectidList = [];
  List<String> totalList = [];
  String _token = "", _id = "";
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
    Map<String, String> params = {
      "student_id": _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(
          await InfixApi.getApiUrl() + InfixApi.getSyllabusSubjectsUrl(),
        ),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final dataArray = jsonData['subjects'];

        setState(() {
          for (var data in dataArray) {
            if (data['subject_code'] == '') {
              subjectNameList.add(data['subject_name']);
            } else {
              subjectNameList.add(
                '${data['subject_name']}(${data['subject_code']})',
              );
            }
            totalCompleteList.add(data['total_complete']);
            idList.add(data['id']);
            subjectidList.add(data['subject_group_subject_id']);
            totalList.add(data['total']);
          }
        });
      }
    } catch (e) {
      print('student syllabus status error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomScreenAppBarWidget(title: 'Syllabus Status'),
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
                        'Loading Syllabus...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : subjectNameList.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.indigo[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school,
                          size: 80,
                          color: Colors.indigo[300],
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'No Syllabus Available',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Syllabus data will appear here once available',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          loadData();
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[600],
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
                    loadData();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: subjectNameList.length,
                    itemBuilder: (context, index) {
                      return StudentSyllabusStatusAdapter(
                        subjectName: subjectNameList[index],
                        totalComplete: totalCompleteList[index],
                        total: totalList[index],
                        onLessonTap: () {
                          showLessonDialog(subjectidList[index], idList[index]);
                        },
                      );
                    },
                  ),
                ),
      ),
    );
  }

  Future<void> showLessonDialog(String subjectId, String sectionId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => StudentSyllabusLesson(
              subjectId: subjectId,
              sectionId: sectionId,
            ),
      ),
    );
  }
}

class StudentSyllabusStatusAdapter extends StatelessWidget {
  final String subjectName;
  final String totalComplete;
  final String total;
  final VoidCallback onLessonTap;

  const StudentSyllabusStatusAdapter({
    super.key,
    required this.subjectName,
    required this.totalComplete,
    required this.total,
    required this.onLessonTap,
  });

  double get completionPercentage {
    if (total == '0') return 0.0;
    return (int.parse(totalComplete) / int.parse(total)) * 100;
  }

  Color get progressColor {
    if (completionPercentage == 0) return Colors.grey[400]!;
    if (completionPercentage < 30) return Colors.red[400]!;
    if (completionPercentage < 70) return Colors.orange[400]!;
    return Colors.green[400]!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 3,
        shadowColor: Colors.grey.withValues(alpha: 0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onLessonTap,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Subject Icon and Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo[400]!, Colors.indigo[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withValues(alpha: 0.3),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.subject, size: 24, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subjectName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.assessment,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Progress Status',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Progress Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Completion Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: progressColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: progressColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              total == '0'
                                  ? '0% Complete'
                                  : '${completionPercentage.toStringAsFixed(0)}% Complete',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: progressColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Progress Bar
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: completionPercentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  progressColor.withValues(alpha: 0.8),
                                  progressColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$totalComplete completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Total: $total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onLessonTap,
                    icon: Icon(Icons.topic, size: 18),
                    label: Text(
                      'View Lesson Topics',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
