import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/main.dart';
import 'package:infixedu/screens/student/examination/ExamResultData.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentExamResult extends StatefulWidget {
  final String examGroupId;

  const StudentExamResult({super.key, required this.examGroupId});

  @override
  _StudentExamResultState createState() => _StudentExamResultState();
}

class _StudentExamResultState extends State<StudentExamResult> {
  ExamResultData? examData;
  String _token = '', _id = '';
  int _studentId = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await _loadTokenAndId();
    loadData();
  }

  Future<void> _loadTokenAndId() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
  }

  // Helper function to print structured data with full response
  void _printStructuredData(String title, String content) {
    print('=== $title ===');
    print('Response Length: ${content.length} characters');
    print('Full Response:');
    try {
      final jsonData = jsonDecode(content);
      final formattedJson = JsonEncoder.withIndent('  ').convert(jsonData);
      print('Formatted JSON:');
      printAll(formattedJson);
      print('JSON Length: ${formattedJson.length} characters');
    } catch (e) {
      print('Raw Response (JSON Parse Failed):');
      print(content);
      print('JSON Parse Error: $e');
    }
    print('=== END $title ===');
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'student_id': _studentId.toString(),
      'exam_group_class_batch_exam_id': widget.examGroupId,
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    final apiUrl = await InfixApi.getApiUrl() + InfixApi.getExamResultUrl();
    final requestBody = json.encode(params);
    final headers = Utils.setHeaderNew(_token.toString(), _id.toString());

    // Structured API request logging
    print('=== EXAM RESULT API REQUEST LOG ===');
    print('URL: $apiUrl');
    print('Method: POST');
    print('Headers: $headers');
    print('Request Body:');
    print(JsonEncoder.withIndent('  ').convert(params));
    print('=== END EXAM RESULT API REQUEST LOG ===');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBody,
      );

      // Structured API response logging
      print('=== EXAM RESULT API RESPONSE LOG ===');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Response Body:');
      _printStructuredData('EXAM RESULT RESPONSE BODY', response.body);
      print('=== END EXAM RESULT API RESPONSE LOG ===');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final jsonData = jsonDecode(response.body);
          print('=== EXAM RESULT DATA PROCESSING ===');
          print('Parsed JSON Data:');
          print(JsonEncoder.withIndent('  ').convert(jsonData));

          if (jsonData.containsKey('exam')) {
            print('Exam data found, processing...');
            examData = ExamResultData.fromJson(jsonData['exam']);
            print('Exam data processed successfully');
            print('Exam Type: ${examData?.examType}');
            print('Total Subjects: ${examData?.subjectResult?.length}');
            print('Is Consolidated: ${examData?.isConsolidate}');
          } else {
            print('No exam data found in response');
          }
          print('=== END EXAM RESULT DATA PROCESSING ===');
        } else {
          print('Response body is empty');
        }
      } else {
        print('API request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('=== EXAM RESULT ERROR ===');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: ${e.toString()}');
      print('Stack Trace:');
      print(e);
      print('=== END EXAM RESULT ERROR ===');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Exam Result'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : examData == null
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
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                    top: 8.0,
                    bottom: 20.0,
                  ),
                  child: Column(
                    children: [
                      // Check for isConsolidate and show "Consolidate Marksheet"
                      if (examData?.isConsolidate == "1")
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          color:
                              Colors.grey[200], // Or any other color you prefer
                          child: Center(
                            child: Text(
                              "Consolidate MarksSheet",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      // Provide some spacing
                      Expanded(
                        child: ListView.builder(
                          itemCount: examData?.subjectResult?.length,
                          itemBuilder:
                              (context, index) =>
                                  examData?.examType == 'gpa'
                                      ? gpaResultCard(index)
                                      : basicResultCard(index),
                        ),
                      ),
                      Divider(),
                      examData?.examType == 'gpa'
                          ? gpaResultSummary()
                          : basicResultSummary(),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget gpaResultSummary() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Credit Hours: ${examData?.examCreditHour}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Quality Points: ${examData?.examCreditHour == "0" ? examData?.examCreditHour : (examData?.examQualityPoints != null && examData?.examCreditHour != null ? (int.parse(examData!.examQualityPoints!) / int.parse(examData!.examCreditHour!)).toStringAsFixed(2) : 'N/A')}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget basicResultSummary() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            // This makes sure the column takes up all available space on the left
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Grand Total: ${examData?.totalGetMarks}/${examData?.totalMaxMarks}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Percentage: ${examData?.percentage}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Division: ${examData?.division}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12), // Space between Column and Card
          Card(
            color:
                examData?.examResultStatus?.toLowerCase() == 'pass'
                    ? Colors.green
                    : Colors.red,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                examData?.examResultStatus?.toUpperCase() ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget gpaResultCard(int index) {
    var subject = examData?.subjectResult?[index];
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.check_circle, color: Colors.blue),
        title: Text(subject?.name ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Grade Point: ${subject?.examGradePoint ?? 'N/A'}"),
            Text("Credit Hours: ${subject?.creditHours ?? 'N/A'}"),
            Text("Quality: ${subject?.examQualityPoints ?? 'N/A'}"),
            Text("Note: ${subject?.note ?? 'N/A'}"),
          ],
        ),
        trailing: Text(
          subject?.examGrade ?? 'N/A',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget basicResultCard(int index) {
    var subject = examData?.subjectResult?[index];
    bool isPassed =
        double.parse(subject?.getMarks ?? '0') >=
        double.parse(subject?.minMarks ?? '0');
    var obtainedMarks =
        subject?.attendance?.toLowerCase() == 'absent'
            ? 'ABS/${subject?.maxMarks}'
            : '${subject?.getMarks}/${subject?.maxMarks}';
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading:
            isPassed
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.error, color: Colors.red),
        title: Text(subject?.name ?? 'N/A'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Obtained Marks: $obtainedMarks"),
            Text("Passing Marks: ${subject?.minMarks}"),
            Text("Note: ${subject?.note}"),
          ],
        ),
        trailing: Text(
          isPassed ? "P" : "F",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isPassed ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
