import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/main.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
// Import other necessary packages

class StudentOnlineExamResult extends StatefulWidget {
  final String onlineExamStudentId;
  final String examId;
  final String examName;

  const StudentOnlineExamResult({
    super.key,
    required this.onlineExamStudentId,
    required this.examId,
    required this.examName,
  });

  @override
  _StudentOnlineExamResultState createState() =>
      _StudentOnlineExamResultState();
}

class ExamResultData {
  final String? exam;
  final String? duration;
  final String? attempt;
  final String? fromDate;
  final String? toDate;
  final String? percent;
  final String? totalQuest;
  final String? correct;
  final String? wrong;
  final String? notAttempt;
  final String? score;
  final List<QuestionResult>? questionResults;

  ExamResultData({
    this.exam,
    this.duration,
    this.attempt,
    this.fromDate,
    this.toDate,
    this.percent,
    this.totalQuest,
    this.correct,
    this.wrong,
    this.notAttempt,
    this.score,
    this.questionResults,
  });
}

class QuestionResult {
  final String? id;
  final String? question;
  final String? subjectName;
  final String? answer;
  final String? correct;
  final String? correctText;
  final String? selectedOption;
  final String? selectedText;
  final String? questionType;
  final String? marks;
  final String? scoreMarks;
  final Map<String, String>? options;

  QuestionResult({
    this.id,
    this.question,
    this.subjectName,
    this.answer,
    this.correct,
    this.correctText,
    this.selectedOption,
    this.selectedText,
    this.questionType,
    this.marks,
    this.scoreMarks,
    this.options,
  });
}

class _StudentOnlineExamResultState extends State<StudentOnlineExamResult> {
  ExamResultData? _examResultData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadData();
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    Map params = {
      'onlineexam_student_id': widget.onlineExamStudentId,
      'exam_id': widget.examId,
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    final apiUrl =
        await InfixApi.getApiUrl() + InfixApi.getOnlineExamResultUrl();
    final requestBody = json.encode(params);
    final headers = Utils.setHeaderNew(
      await Utils.getStringValue('token'),
      await Utils.getStringValue('id'),
    );

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
      _printStructuredData('RESPONSE BODY', response.body);
      print('=== END API RESPONSE LOG ===');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        await processData(jsonData);
      }
    } catch (e) {
      print('Student exam result error = ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> processData(Map<String, dynamic> jsonData) async {
    final resultData = jsonData['result'];
    final examData = resultData['exam'];

    List<QuestionResult> questionResults = List<QuestionResult>.from(
      resultData['question_result'].map((result) {
        // Parse correct answer (can be array for multichoice)
        String correctAnswer = result['correct'] ?? '';
        List<String> correctOptions = [];

        if (correctAnswer.startsWith('[') && correctAnswer.endsWith(']')) {
          // Handle array format like ["opt_a"]
          try {
            List<dynamic> parsed = jsonDecode(correctAnswer);
            correctOptions = parsed.cast<String>();
          } catch (e) {
            correctOptions = [correctAnswer];
          }
        } else {
          correctOptions = [correctAnswer];
        }

        // Get correct answer text
        String correctText = "";
        for (String correctOpt in correctOptions) {
          if (result.containsKey(correctOpt) && result[correctOpt] != null) {
            correctText +=
                (correctText.isNotEmpty ? ", " : "") + result[correctOpt];
          }
        }

        // Get selected answer text
        String selectedText = "";
        String selectedOption = result['select_option'] ?? '';

        if (selectedOption.isNotEmpty && selectedOption != 'null') {
          if (result.containsKey(selectedOption) &&
              result[selectedOption] != null) {
            selectedText = result[selectedOption];
          }
        }

        // Determine answer status
        String answerStatus = "Not Attempted";
        if (selectedOption.isNotEmpty && selectedOption != 'null') {
          if (correctOptions.contains(selectedOption)) {
            answerStatus = "Correct";
          } else {
            answerStatus = "Incorrect";
          }
        }

        // Create options map
        Map<String, String> options = {};
        for (final option in ['opt_a', 'opt_b', 'opt_c', 'opt_d', 'opt_e']) {
          if (result.containsKey(option) &&
              result[option] != null &&
              result[option].toString().isNotEmpty) {
            options[option] = result[option];
          }
        }

        return QuestionResult(
          id: result['id'],
          question: result['question'],
          subjectName: result['subject_name'],
          answer: answerStatus,
          correct: correctAnswer,
          correctText: correctText,
          selectedOption: selectedOption,
          selectedText: selectedText,
          questionType: result['question_type'],
          marks: result['marks'],
          scoreMarks: result['score_marks'],
          options: options,
        );
      }),
    );

    _examResultData = ExamResultData(
      exam: examData['exam'],
      duration: examData['duration'],
      attempt: examData['attempt'],
      fromDate: Utils.parseDate(
        'yyyy-MM-dd HH:mm:ss',
        'dd/MM/yyyy HH:mm',
        examData['exam_from'],
      ),
      toDate: Utils.parseDate(
        'yyyy-MM-dd HH:mm:ss',
        'dd/MM/yyyy HH:mm',
        examData['exam_to'],
      ),
      percent: examData['passing_percentage'],
      totalQuest: examData['total_question'].toString(),
      correct: examData['correct_ans'].toString(),
      wrong: examData['wrong_ans'].toString(),
      notAttempt: examData['not_attempted'].toString(),
      score: examData['score'].toString(),
      questionResults: questionResults,
    );
  }

  Widget _buildInfoRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$title:',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: '${widget.examName} Result'),
      body: SafeArea(
        child:
            _isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(radius: 20),
                      SizedBox(height: 16),
                      Text(
                        'Loading exam results...',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
                : _examResultData == null
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
                        'No Results Available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Results may not be published yet',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Summary Card
                      _buildSummaryCard(isSmallScreen),
                      SizedBox(height: 20),

                      // Statistics Cards
                      _buildStatisticsCards(isSmallScreen),
                      SizedBox(height: 20),

                      // Questions Section
                      _buildQuestionsSection(isSmallScreen),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildSummaryCard(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment,
                color: Colors.blue,
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  _examResultData?.exam ?? 'Exam Result',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Score Display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getScoreColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getScoreColor().withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Your Score',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${_examResultData?.score ?? "0"}%',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 32 : 36,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Scored: ${_examResultData?.questionResults?.fold(0.0, (sum, q) => sum + (double.tryParse(q.scoreMarks ?? '0') ?? 0)).toStringAsFixed(2)} / ${_examResultData?.questionResults?.fold(0.0, (sum, q) => sum + (double.tryParse(q.marks ?? '0') ?? 0)).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _getScoreMessage(),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: _getScoreColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(bool isSmallScreen) {
    final stats = [
      {
        'title': 'Total Questions',
        'value': _examResultData?.totalQuest ?? '0',
        'icon': Icons.quiz,
        'color': Colors.blue,
      },
      {
        'title': 'Correct',
        'value': _examResultData?.correct ?? '0',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'Wrong',
        'value': _examResultData?.wrong ?? '0',
        'icon': Icons.cancel,
        'color': Colors.red,
      },
      {
        'title': 'Not Attempted',
        'value': _examResultData?.notAttempt ?? '0',
        'icon': Icons.help_outline,
        'color': Colors.orange,
      },
    ];

    return isSmallScreen
        ? Column(
          children:
              stats.map((stat) => _buildStatCard(stat, isSmallScreen)).toList(),
        )
        : Row(
          children:
              stats
                  .map(
                    (stat) =>
                        Expanded(child: _buildStatCard(stat, isSmallScreen)),
                  )
                  .toList(),
        );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isSmallScreen ? 12 : 0,
        right: isSmallScreen ? 0 : 8,
      ),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            stat['icon'],
            color: stat['color'],
            size: isSmallScreen ? 24 : 28,
          ),
          SizedBox(height: 8),
          Text(
            stat['value'],
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: stat['color'],
            ),
          ),
          SizedBox(height: 4),
          Text(
            stat['title'],
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Details',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),

        // Exam details
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              if (isSmallScreen) ...[
                _buildInfoRow('Duration', _examResultData?.duration ?? 'N/A'),
                _buildInfoRow('Attempt', _examResultData?.attempt ?? 'N/A'),
                _buildInfoRow('From Date', _examResultData?.fromDate ?? 'N/A'),
                _buildInfoRow('To Date', _examResultData?.toDate ?? 'N/A'),
                _buildInfoRow(
                  'Passing %',
                  '${_examResultData?.percent ?? "N/A"}%',
                ),
                _buildInfoRow(
                  'Total Marks',
                  '${_examResultData?.questionResults?.fold(0.0, (sum, q) => sum + (double.tryParse(q.marks ?? '0') ?? 0))}',
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        'Duration',
                        _examResultData?.duration ?? 'N/A',
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _buildInfoRow(
                        'Attempt',
                        _examResultData?.attempt ?? 'N/A',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        'From Date',
                        _examResultData?.fromDate ?? 'N/A',
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _buildInfoRow(
                        'To Date',
                        _examResultData?.toDate ?? 'N/A',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        'Passing %',
                        '${_examResultData?.percent ?? "N/A"}%',
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _buildInfoRow(
                        'Total Marks',
                        '${_examResultData?.questionResults?.fold(0.0, (sum, q) => sum + (double.tryParse(q.marks ?? '0') ?? 0))}',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16),

        // Questions list
        ...(_examResultData?.questionResults?.mapIndexed((
              index,
              questionResult,
            ) {
              return StudentExamScheduleAdapter(
                index: index,
                question: questionResult.question ?? '',
                subject: questionResult.subjectName ?? '',
                answer: questionResult.answer ?? '',
                correctOption: questionResult.correct ?? '',
                correctText: questionResult.correctText ?? '',
                selectedOption: questionResult.selectedOption ?? '',
                selectedText: questionResult.selectedText ?? '',
                questionType: questionResult.questionType ?? '',
                marks: questionResult.marks ?? '',
                scoreMarks: questionResult.scoreMarks ?? '',
                options: questionResult.options,
                isSmallScreen: isSmallScreen,
              );
            }).toList() ??
            []),
      ],
    );
  }

  Color _getScoreColor() {
    final score = double.tryParse(_examResultData?.score ?? '0') ?? 0;
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreMessage() {
    final score = double.tryParse(_examResultData?.score ?? '0') ?? 0;
    if (score >= 80) return 'Excellent!';
    if (score >= 60) return 'Good Job!';
    return 'Needs Improvement';
  }
}

class StudentExamScheduleAdapter extends StatelessWidget {
  final int? index;
  final String? question;
  final String? subject;
  final String? answer;
  final String? correctOption;
  final String? correctText;
  final String? selectedOption;
  final String? selectedText;
  final String? questionType;
  final String? marks;
  final String? scoreMarks;
  final Map<String, String>? options;
  final bool isSmallScreen;

  const StudentExamScheduleAdapter({
    super.key,
    this.index,
    this.question,
    this.subject,
    this.answer,
    this.correctOption,
    this.correctText,
    this.selectedOption,
    this.selectedText,
    this.questionType,
    this.marks,
    this.scoreMarks,
    this.options,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
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
            // Header with question number and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Q${index != null ? (index! + 1) : ''}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: getColorForAnswer(answer ?? '').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: getColorForAnswer(answer ?? '').withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: getColorForAnswer(answer ?? ''),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          answer ?? '',
                          style: TextStyle(
                            color: getColorForAnswer(answer ?? ''),
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Question text
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Html(
                    data: question ?? '',
                    style: {
                      "body": Style(
                        fontSize: FontSize(isSmallScreen ? 14 : 16),
                        color: Colors.black87,
                        lineHeight: LineHeight(1.5),
                      ),
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Subject and marks
            if (isSmallScreen) ...[
              _buildInfoRow('Subject', subject ?? 'N/A'),
              _buildInfoRow('Question Type', questionType ?? 'N/A'),
              _buildInfoRow(
                'Marks',
                '${marks ?? '0'} (Scored: ${scoreMarks ?? '0'})',
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _buildInfoRow('Subject', subject ?? 'N/A')),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildInfoRow(
                      'Question Type',
                      questionType ?? 'N/A',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      'Marks',
                      '${marks ?? '0'} (Scored: ${scoreMarks ?? '0'})',
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(child: Container()),
                ],
              ),
            ],

            SizedBox(height: 12),

            // User's Answer
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getColorForAnswer(answer ?? '').withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: getColorForAnswer(answer ?? '').withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Answer:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    selectedText?.isNotEmpty == true
                        ? selectedText!
                        : (selectedOption?.isNotEmpty == true &&
                                selectedOption != 'null'
                            ? 'Option ${selectedOption!.toUpperCase()}'
                            : 'Not Attempted'),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: getColorForAnswer(answer ?? ''),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Correct Answer
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Correct Answer:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    correctText?.isNotEmpty == true ? correctText! : 'N/A',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // All Options (if available)
            if (options != null && options!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Options:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 13 : 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    ...options!.entries.map((entry) {
                      bool isCorrect =
                          correctOption?.contains(entry.key) == true;
                      bool isSelected = selectedOption == entry.key;

                      return Container(
                        margin: EdgeInsets.only(bottom: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isCorrect
                                  ? Colors.green.withOpacity(0.1)
                                  : isSelected
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color:
                                isCorrect
                                    ? Colors.green.withOpacity(0.3)
                                    : isSelected
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key.toUpperCase()}: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 12 : 13,
                                color:
                                    isCorrect
                                        ? Colors.green[700]
                                        : isSelected
                                        ? Colors.red[700]
                                        : Colors.grey[700],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  color:
                                      isCorrect
                                          ? Colors.green[700]
                                          : isSelected
                                          ? Colors.red[700]
                                          : Colors.grey[700],
                                ),
                              ),
                            ),
                            if (isCorrect)
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: isSmallScreen ? 16 : 18,
                              ),
                            if (isSelected && !isCorrect)
                              Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: isSmallScreen ? 16 : 18,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getColorForAnswer(String answer) {
    if (answer == 'Correct') {
      return Colors.green;
    } else if (answer == 'Incorrect') {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }
}
