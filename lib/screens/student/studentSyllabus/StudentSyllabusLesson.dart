import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:intl/intl.dart';

class StudentSyllabusLesson extends StatefulWidget {
  final String subjectId;
  final String sectionId;

  const StudentSyllabusLesson({
    super.key,
    required this.subjectId,
    required this.sectionId,
  });

  @override
  _StudentSyllabusLessonState createState() => _StudentSyllabusLessonState();
}

class _StudentSyllabusLessonState extends State<StudentSyllabusLesson> {
  List<String> nameList = [];
  List<String> totalCompleteList = [];
  List<String> totalList = [];
  List<String> topicArray = [];
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
        getDataFromApi();
      });
    });
    super.initState();
  }

  Future<void> getDataFromApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      Map<String, String> params = {
        "subject_group_subject_id": widget.subjectId,
        "subject_group_class_sections_id": widget.sectionId,
        'schoolId': await Utils.getStringValue('schoolId'),
      };
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getSyllabusLessonUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        responseData.forEach((lesson) {
          nameList.add(lesson["name"]);
          totalCompleteList.add(lesson["total_complete"].toString());
          totalList.add(lesson["total"].toString());
          topicArray.add(jsonEncode(lesson["topics"]));
        });
        setState(() {});
      }
    } catch (e) {
      print('Student syllabus lesson error = ${e.toString()}');
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
      appBar: CustomScreenAppBarWidget(title: 'Lesson Topic'),
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
                        'Loading Lessons...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : nameList.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.topic,
                          size: 80,
                          color: Colors.purple[300],
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'No Lessons Available',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Lesson topics will appear here once available',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          getDataFromApi();
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
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
                  onRefresh: getDataFromApi,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: nameList.length,
                    itemBuilder: (context, index) {
                      return LessonCard(
                        position: index,
                        name: nameList[index],
                        totalComplete: totalCompleteList[index],
                        total: totalList[index],
                        topics: topicArray[index],
                      );
                    },
                  ),
                ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final int position;
  final String name;
  final String totalComplete;
  final String total;
  final String topics;

  const LessonCard({
    super.key,
    required this.position,
    required this.name,
    required this.totalComplete,
    required this.total,
    required this.topics,
  });

  double get completionPercentage {
    if (total == "0") return 0.0;
    return (int.parse(totalComplete) / int.parse(total)) * 100;
  }

  Color get progressColor {
    if (completionPercentage == 0) return Colors.grey[400]!;
    if (completionPercentage < 30) return Colors.red[400]!;
    if (completionPercentage < 70) return Colors.orange[400]!;
    return Colors.green[400]!;
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> topicArray = jsonDecode(topics);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 3,
        shadowColor: Colors.grey.withValues(alpha: 0.2),
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
              // Lesson Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[400]!, Colors.purple[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${position + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
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
                            total == "0"
                                ? "No Status"
                                : "${completionPercentage.toStringAsFixed(0)}% Completed",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: progressColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (total != "0") ...[
                SizedBox(height: 16),
                // Progress Bar
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
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
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: 20),

              // Topics Section
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
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 20,
                          color: Colors.purple[700],
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Topics (${topicArray.length})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Topics List
                    for (int i = 0; i < topicArray.length; i++) ...[
                      Container(
                        margin: EdgeInsets.only(
                          bottom: i == topicArray.length - 1 ? 0 : 12,
                        ),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                topicArray[i]["status"] == "1"
                                    ? Colors.green[200]!
                                    : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 2),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color:
                                        topicArray[i]["status"] == "1"
                                            ? Colors.green[600]
                                            : Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${position + 1}.${i + 1} ${topicArray[i]["name"]}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        topicArray[i]["status"] == "1"
                                            ? Colors.green[100]
                                            : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        topicArray[i]["status"] == "1"
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: 12,
                                        color:
                                            topicArray[i]["status"] == "1"
                                                ? Colors.green[700]
                                                : Colors.grey[600],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        topicArray[i]["status"] == "1"
                                            ? "Complete"
                                            : "Incomplete",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              topicArray[i]["status"] == "1"
                                                  ? Colors.green[700]
                                                  : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (topicArray[i]["status"] == "1" &&
                                topicArray[i]["complete_date"] != null) ...[
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 14,
                                  ), // Align with bullet point
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: Colors.green[600],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Completed: ${_formatDate(topicArray[i]["complete_date"])}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
