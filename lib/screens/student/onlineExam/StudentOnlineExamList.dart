import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/main.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:infixedu/screens/student/onlineExam/OnlineExamItem.dart';
import 'package:infixedu/screens/student/onlineExam/StudentOnlineExamQuestions.dart';
import 'package:infixedu/screens/student/onlineExam/StudentOnlineExamResult.dart';

class StudentOnlineExamList extends StatefulWidget {
  const StudentOnlineExamList({super.key});

  @override
  _StudentOnlineExamListState createState() => _StudentOnlineExamListState();
}

class _StudentOnlineExamListState extends State<StudentOnlineExamList> {
  bool isLoading = false;
  List<OnlineExamItem> examList = [];
  String _token = '', _id = '';
  int _studentId = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'student_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    final apiUrl = await InfixApi.getApiUrl() + InfixApi.getOnlineExamUrl();
    final requestBody = json.encode(params);
    final headers = Utils.setHeaderNew(_token.toString(), _id.toString());

    // Structured API request logging
    print('=== API REQUEST LOG ===');
    print('URL: $apiUrl');
    print('Method: POST');
    print('Headers: $headers');
    print('Request Body:');
    print(JsonEncoder.withIndent('  ').convert(params));
    print('=== END API REQUEST LOG ===');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBody,
      );

      // Structured API response logging
      print('=== API RESPONSE LOG ===');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Response Body:');
      try {
        final jsonData = jsonDecode(response.body);
        printAll(JsonEncoder.withIndent('  ').convert(jsonData));
      } catch (e) {
        print('Raw Response: ${response.body}');
        print('JSON Parse Error: $e');
      }
      print('=== END API RESPONSE LOG ===');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        await processData(jsonData);
      }
    } catch (e) {
      print('Student online exam list error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> processData(Map<String, dynamic> jsonData) async {
    examList.clear();
    List<dynamic> dataArray = jsonData['onlineexam'];
    examList =
        dataArray.map((examData) {
          return OnlineExamItem(
            examId: examData['id'],
            examStudentId: examData['onlineexam_student_id'],
            examName: examData['exam'],
            duration: examData['duration'],
            totalAttempts: examData['attempt'],
            attempted: examData['attempts'],
            dateFrom: Utils.parseDate(
              'yyyy-MM-dd HH:mm:ss',
              'dd/MM/yyyy HH:mm',
              examData['exam_from'],
            ),
            dateTo: Utils.parseDate(
              'yyyy-MM-dd HH:mm:ss',
              'dd/MM/yyyy HH:mm',
              examData['exam_to'],
            ),
            status: examData['publish_result'],
            isSubmitted: examData['is_submitted'],
            isAttempted: examData['is_attempted'],
            totalQuestions: examData['total_question'],
            totalDescriptive: examData['total_descriptive'],
            passingPercentage: examData['passing_percentage'],
            description: examData['description'],
            isActive: examData['is_active'],
            isQuiz: examData['is_quiz'],
            autoPublishDate: Utils.parseDate(
              'yyyy-MM-dd HH:mm:ss',
              'dd/MM/yyyy HH:mm',
              examData['auto_publish_date'],
            ),
          );
        }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Online Exams'),
      body: SafeArea(
        child:
            isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(radius: 20),
                      SizedBox(height: 16),
                      Text(
                        'Loading exams...',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
                : examList.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/no_data.png',
                        width: 200,
                        height: 200,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No Online Exams Available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check back later for new exams',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
                    itemCount: examList.length,
                    itemBuilder: (context, index) {
                      return StudentOnlineExamListItem(
                        exam: examList[index],
                        onViewResultPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => StudentOnlineExamResult(
                                    examName: examList[index].examName ?? "",
                                    examId: examList[index].examId ?? "",
                                    onlineExamStudentId:
                                        examList[index].examStudentId ?? "",
                                  ),
                            ),
                          );
                        },
                        onStartExamPressed: () async {
                          final totalAttempts =
                              int.tryParse(
                                examList[index].totalAttempts ?? "0",
                              ) ??
                              0;
                          final attempted =
                              int.tryParse(examList[index].attempted ?? "0") ??
                              0;

                          if (attempted >= totalAttempts) {
                            Fluttertoast.showToast(
                              msg:
                                  "You have reached the maximum number of attempts ($totalAttempts)!",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          } else {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => StudentOnlineExamQuestions(
                                      examName: examList[index].examName ?? "",
                                      onlineExamId:
                                          examList[index].examId ?? "",
                                      onlineStudentExamId:
                                          examList[index].examStudentId ?? "",
                                    ),
                              ),
                            );
                            print('startExam result = $result');
                            if (result == true) {
                              loadData();
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
      ),
    );
  }
}

class StudentOnlineExamListItem extends StatelessWidget {
  final OnlineExamItem exam;
  final Function() onViewResultPressed;
  final Function() onStartExamPressed;

  const StudentOnlineExamListItem({
    super.key,
    required this.exam,
    required this.onViewResultPressed,
    required this.onStartExamPressed,
  });

  Widget buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getStatusColor() {
    if (exam.status == '1') {
      return Colors.green;
    } else if (exam.isSubmitted == '1') {
      return Colors.orange;
    } else if (exam.isAttempted == '1') {
      return Colors.purple;
    } else {
      return Colors.blue;
    }
  }

  String getStatusText() {
    if (exam.status == '1') {
      return 'Result Published';
    } else if (exam.isSubmitted == '1') {
      return 'Submitted';
    } else if (exam.isAttempted == '1') {
      return 'Attempted';
    } else {
      return 'Available';
    }
  }

  String getButtonText() {
    final totalAttempts = int.tryParse(exam.totalAttempts ?? "0") ?? 0;
    final attempted = int.tryParse(exam.attempted ?? "0") ?? 0;

    if (exam.status == '1') {
      return 'View Result';
    } else if (attempted >= totalAttempts) {
      return 'No Attempts Left';
    } else if (exam.isSubmitted == '1' || exam.isAttempted == '1') {
      return 'Retry Exam';
    } else {
      return 'Start Exam';
    }
  }

  Color getButtonColor() {
    final totalAttempts = int.tryParse(exam.totalAttempts ?? "0") ?? 0;
    final attempted = int.tryParse(exam.attempted ?? "0") ?? 0;

    if (exam.status == '1') {
      return Colors.green;
    } else if (attempted >= totalAttempts) {
      return Colors.grey;
    } else if (exam.isSubmitted == '1' || exam.isAttempted == '1') {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  bool isButtonEnabled() {
    final totalAttempts = int.tryParse(exam.totalAttempts ?? "0") ?? 0;
    final attempted = int.tryParse(exam.attempted ?? "0") ?? 0;

    return exam.status == '1' || attempted < totalAttempts;
  }

  Color _getAttemptColor() {
    final totalAttempts = int.tryParse(exam.totalAttempts ?? "0") ?? 0;
    final attempted = int.tryParse(exam.attempted ?? "0") ?? 0;

    if (attempted >= totalAttempts) {
      return Colors.red;
    } else if (attempted > 0) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with exam name and action button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    exam.examName ?? "Untitled Exam",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 16 : 18,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12),
                // Action button
                ElevatedButton.icon(
                  onPressed:
                      isButtonEnabled()
                          ? (exam.status == '1'
                              ? onViewResultPressed
                              : onStartExamPressed)
                          : null,
                  icon: Icon(
                    exam.status == '1' ? Icons.visibility : Icons.play_arrow,
                    size: 16,
                  ),
                  label: Text(getButtonText(), style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getButtonColor(),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Status indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: getStatusColor().withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: getStatusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    getStatusText(),
                    style: TextStyle(
                      color: getStatusColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Exam details in responsive layout
            if (isSmallScreen)
              // Single column layout for small screens
              Column(
                children: [
                  buildInfoRow('Date From', exam.dateFrom ?? "N/A"),
                  buildInfoRow('Date To', exam.dateTo ?? "N/A"),
                  buildInfoRow('Duration', exam.duration ?? "N/A"),
                  buildInfoRow('Total Questions', exam.totalQuestions ?? "N/A"),
                  if (exam.totalDescriptive != null &&
                      exam.totalDescriptive != "0")
                    buildInfoRow(
                      'Descriptive Questions',
                      exam.totalDescriptive ?? "N/A",
                    ),
                  buildInfoRow(
                    'Passing %',
                    '${exam.passingPercentage ?? "N/A"}%',
                  ),
                  buildInfoRow('Total Attempts', exam.totalAttempts ?? "N/A"),
                  buildInfoRow(
                    'Attempted',
                    '${exam.attempted ?? "0"}/${exam.totalAttempts ?? "0"}',
                    valueColor: _getAttemptColor(),
                  ),
                  if (exam.description?.isNotEmpty == true)
                    buildInfoRow('Description', exam.description ?? "N/A"),
                ],
              )
            else
              // Two column layout for larger screens
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        buildInfoRow('Date From', exam.dateFrom ?? "N/A"),
                        buildInfoRow('Date To', exam.dateTo ?? "N/A"),
                        buildInfoRow('Duration', exam.duration ?? "N/A"),
                        buildInfoRow(
                          'Total Questions',
                          exam.totalQuestions ?? "N/A",
                        ),
                        if (exam.totalDescriptive != null &&
                            exam.totalDescriptive != "0")
                          buildInfoRow(
                            'Descriptive Questions',
                            exam.totalDescriptive ?? "N/A",
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        buildInfoRow(
                          'Passing %',
                          '${exam.passingPercentage ?? "N/A"}%',
                        ),
                        buildInfoRow(
                          'Total Attempts',
                          exam.totalAttempts ?? "N/A",
                        ),
                        buildInfoRow(
                          'Attempted',
                          '${exam.attempted ?? "0"}/${exam.totalAttempts ?? "0"}',
                          valueColor: _getAttemptColor(),
                        ),
                        buildInfoRow('Status', getStatusText()),
                        if (exam.description?.isNotEmpty == true)
                          buildInfoRow(
                            'Description',
                            exam.description ?? "N/A",
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
