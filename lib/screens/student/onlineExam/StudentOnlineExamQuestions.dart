import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:infixedu/main.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';

// Question Type Enum
enum QuestionType { multichoice, true_false, descriptive, singlechoice }

// Question Model
class Question {
  final String questionId;
  final String question;
  final String questionType;
  final String? selectedOption;
  final String? descriptiveAnswer;
  final Map<String, String> options;
  final String correct;
  final String marks;
  final String negMarks;

  Question({
    required this.questionId,
    required this.question,
    required this.questionType,
    this.selectedOption,
    this.descriptiveAnswer,
    required this.options,
    required this.correct,
    required this.marks,
    required this.negMarks,
  });

  Question copyWith({String? selectedOption, String? descriptiveAnswer}) {
    return Question(
      questionId: questionId,
      question: question,
      questionType: questionType,
      selectedOption: selectedOption ?? this.selectedOption,
      descriptiveAnswer: descriptiveAnswer ?? this.descriptiveAnswer,
      options: options,
      correct: correct,
      marks: marks,
      negMarks: negMarks,
    );
  }

  QuestionType get type {
    switch (questionType) {
      case 'multichoice':
        return QuestionType.multichoice;
      case 'true_false':
        return QuestionType.true_false;
      case 'descriptive':
        return QuestionType.descriptive;
      case 'singlechoice':
        return QuestionType.singlechoice;
      default:
        return QuestionType.multichoice;
    }
  }

  bool get isAnswered {
    switch (type) {
      case QuestionType.descriptive:
        return descriptiveAnswer != null &&
            descriptiveAnswer!.trim().isNotEmpty;
      default:
        return selectedOption != null && selectedOption!.isNotEmpty;
    }
  }
}

class StudentOnlineExamQuestions extends StatefulWidget {
  final String examName, onlineExamId, onlineStudentExamId;
  const StudentOnlineExamQuestions({
    super.key,
    required this.examName,
    required this.onlineExamId,
    required this.onlineStudentExamId,
  });
  @override
  _StudentOnlineExamQuestionsState createState() =>
      _StudentOnlineExamQuestionsState();
}

class _StudentOnlineExamQuestionsState
    extends State<StudentOnlineExamQuestions> {
  List<Question> questions = [];
  List<Map<String, dynamic>> userResponses = [];
  int currentQuestionIndex = 0;
  Question? currentQuestion;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool isLoading = false, isSubmitting = false;
  String _token = '', _id = '';
  int _studentId = 0;
  final TextEditingController _descriptiveController = TextEditingController();
  final FocusNode _descriptiveFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeData();

    // Add focus listener for descriptive text field
    _descriptiveFocusNode.addListener(() {
      if (_descriptiveFocusNode.hasFocus) {
        // Scroll to make text field visible when it gains focus
        Future.delayed(Duration(milliseconds: 500), () {
          Scrollable.ensureVisible(
            context,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _descriptiveController.dispose();
    _descriptiveFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
    loadData();
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
      'online_exam_id': widget.onlineExamId,
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    final apiUrl =
        await InfixApi.getApiUrl() + InfixApi.getOnlineExamQuestionUrl();
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
      _printStructuredData('RESPONSE BODY', response.body);
      print('=== END API RESPONSE LOG ===');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final examObject = jsonData['exam'];
        _secondsRemaining = _calculateTotalSeconds(examObject['duration']);
        List<dynamic> questionsList = examObject['questions'];
        await processData(questionsList);
      }
    } catch (e) {
      print('Student online exam questions error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> processData(List<dynamic> questionsList) async {
    questions =
        questionsList.map((questionData) {
          Map<String, String> options = {};

          // Add options based on question type
          if (questionData['question_type'] == 'multichoice') {
            // Add all options A, B, C, D, E for multichoice
            for (final option in [
              'opt_a',
              'opt_b',
              'opt_c',
              'opt_d',
              'opt_e',
            ]) {
              if (questionData.containsKey(option) &&
                  questionData[option].toString().isNotEmpty) {
                options[option] = questionData[option];
              }
            }
          } else if (questionData['question_type'] == 'singlechoice') {
            // Add only A, B for singlechoice
            for (final option in ['opt_a', 'opt_b']) {
              if (questionData.containsKey(option) &&
                  questionData[option].toString().isNotEmpty) {
                options[option] = questionData[option];
              }
            }
          } else if (questionData['question_type'] == 'true_false') {
            // Add True/False options
            options['true'] = 'True';
            options['false'] = 'False';
          }
          // For descriptive, no options needed

          return Question(
            questionId: questionData['question_id'].toString(),
            question: questionData['question'] ?? '',
            questionType: questionData['question_type'] ?? 'multichoice',
            options: options,
            correct: questionData['correct'] ?? '',
            marks: questionData['marks'] ?? '1.00',
            negMarks: questionData['neg_marks'] ?? '0.25',
          );
        }).toList();

    if (questions.isNotEmpty) {
      currentQuestion = questions[currentQuestionIndex];
      _startTimer();
    }
  }

  Future<bool> _showConfirmationDialog(bool isBackPress) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Submit Exam'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you sure you want to submit your exam?'),
                  SizedBox(height: 16),
                  Text(
                    'Answered: ${questions.where((q) => q.isAnswered).length}/${questions.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  if (questions.where((q) => !q.isAnswered).isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      'You have ${questions.where((q) => !q.isAnswered).length} unanswered questions.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(isBackPress);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    _submitAnswer();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Submit'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void saveResponses(
    Question question, {
    String? selectedOption,
    String? descriptiveAnswer,
  }) {
    final updatedQuestion = question.copyWith(
      selectedOption: selectedOption,
      descriptiveAnswer: descriptiveAnswer,
    );

    final listIndex = questions.indexWhere(
      (element) => element.questionId == question.questionId,
    );

    if (listIndex != -1) {
      questions[listIndex] = updatedQuestion;
    }

    // Update userResponses for API submission
    final existingIndex = userResponses.indexWhere(
      (response) => response['onlineexam_question_id'] == question.questionId,
    );

    Map<String, dynamic> responseData = {
      'onlineexam_student_id': widget.onlineStudentExamId,
      'onlineexam_question_id': question.questionId,
    };

    if (question.type == QuestionType.descriptive) {
      responseData['descriptive_answer'] = descriptiveAnswer ?? '';
    } else {
      responseData['select_option'] = selectedOption ?? '';
    }

    if (existingIndex != -1) {
      userResponses[existingIndex] = responseData;
    } else {
      userResponses.add(responseData);
    }

    print('Updated userResponses: $userResponses');
    print(
      'Question Type: ${question.questionType}, Answer: ${question.type == QuestionType.descriptive ? descriptiveAnswer : selectedOption}',
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_secondsRemaining <= 0) {
        _timer?.cancel();
        _submitAnswer();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _navigateToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        currentQuestion = questions[currentQuestionIndex];
        _descriptiveController.text = currentQuestion?.descriptiveAnswer ?? '';
      });
    } else {
      _timer?.cancel();
    }
  }

  void _submitAnswer() async {
    setState(() {
      isSubmitting = true;
    });

    // Validate and prepare data
    print('=== SUBMIT DATA VALIDATION ===');
    print('Total Questions: ${questions.length}');
    print('User Responses Count: ${userResponses.length}');
    print('Answered Questions: ${questions.where((q) => q.isAnswered).length}');

    // Check for any missing responses
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final hasResponse = userResponses.any(
        (r) => r['onlineexam_question_id'] == question.questionId,
      );
      print(
        'Q${i + 1} (ID: ${question.questionId}, Type: ${question.questionType}): ${hasResponse ? "Answered" : "Not Answered"}',
      );
    }

    Map params = {
      'onlineexam_student_id': widget.onlineStudentExamId,
      'rows': userResponses,
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    final apiUrl = await InfixApi.getApiUrl() + InfixApi.saveOnlineExamUrl();
    final requestBody = json.encode(params);
    final headers = Utils.setHeaderNew(_token.toString(), _id.toString());

    // Structured API request logging for submit
    print('=== SUBMIT API REQUEST LOG ===');
    print('URL: $apiUrl');
    print('Method: POST');
    print('Headers: $headers');
    print('Request Body:');
    print(JsonEncoder.withIndent('  ').convert(params));
    print('=== END SUBMIT API REQUEST LOG ===');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBody,
      );

      // Structured API response logging for submit
      print('=== SUBMIT API RESPONSE LOG ===');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Response Body:');
      _printStructuredData('SUBMIT RESPONSE BODY', response.body);
      print('=== END SUBMIT API RESPONSE LOG ===');

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          Fluttertoast.showToast(
            msg: jsonData['msg'] ?? 'Exam submitted successfully!',
          );
          Navigator.pop(context, true);
        } catch (jsonError) {
          print('JSON Parse Error in success response: $jsonError');
          Fluttertoast.showToast(msg: 'Exam submitted successfully!');
          Navigator.pop(context, true);
        }
      } else {
        // Handle error responses
        String errorMessage =
            'Failed to submit exam. Status: ${response.statusCode}';

        try {
          // Try to parse error response as JSON
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorData['msg'] ?? errorMessage;
        } catch (jsonError) {
          // If it's HTML error page, extract meaningful error
          if (response.body.contains('Database Error')) {
            errorMessage =
                'Database error occurred. Please try again or contact support.';
          } else if (response.body.contains('<!DOCTYPE html>')) {
            errorMessage = 'Server error occurred. Please try again.';
          } else {
            errorMessage = 'Server error: ${response.statusCode}';
          }
        }

        print('Submit Error: $errorMessage');
        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print('Network/Submit Error: ${e.toString()}');
      Fluttertoast.showToast(
        msg: 'Network error. Please check your connection and try again.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  int _calculateTotalSeconds(String durationString) {
    final parts = durationString.split(':');
    return int.parse(parts[0]) * 3600 +
        int.parse(parts[1]) * 60 +
        int.parse(parts[2]);
  }

  void _customBackPress(BuildContext context) {
    _showConfirmationDialog(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _showConfirmationDialog(true),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomScreenAppBarWidget(
          title: widget.examName,
          onBackPress: _customBackPress,
        ),
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
                          'Loading exam questions...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                  : questions.isEmpty
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
                          'No Questions Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                  : _buildQuestionContent(),
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Column(
      children: [
        _buildTopSection(isSmallScreen),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildQuestionOptions(isSmallScreen),
                // Add extra padding at bottom for keyboard
                SizedBox(height: 200),
              ],
            ),
          ),
        ),
        _buildBottomSection(isSmallScreen),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuestionOptions(bool isSmallScreen) {
    if (currentQuestion == null) return Container();

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
          // Question number and type indicator
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Text(
                  'Q${currentQuestionIndex + 1}',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getQuestionTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getQuestionTypeColor().withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getQuestionTypeText(),
                  style: TextStyle(
                    color: _getQuestionTypeColor(),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              if (currentQuestion!.isAnswered)
                Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          SizedBox(height: 20),

          // Question text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Html(
              data: currentQuestion?.question ?? '',
              style: {
                "body": Style(
                  fontSize: FontSize(isSmallScreen ? 16 : 18),
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  lineHeight: LineHeight(1.5),
                ),
              },
            ),
          ),
          SizedBox(height: 24),

          // Question type specific content
          _buildQuestionTypeContent(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildQuestionTypeContent(bool isSmallScreen) {
    switch (currentQuestion?.type) {
      case QuestionType.multichoice:
        return _buildMultichoiceOptions(isSmallScreen);
      case QuestionType.singlechoice:
        return _buildSinglechoiceOptions(isSmallScreen);
      case QuestionType.true_false:
        return _buildTrueFalseOptions(isSmallScreen);
      case QuestionType.descriptive:
        return _buildDescriptiveInput(isSmallScreen);
      default:
        return Container();
    }
  }

  Widget _buildMultichoiceOptions(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your answer (A, B, C, D, E):',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        ...currentQuestion!.options.entries.map((entry) {
          final optionKey = entry.key;
          final optionText = entry.value;
          final isSelected = currentQuestion?.selectedOption == optionKey;

          return _buildOptionTile(
            optionKey: optionKey,
            optionText: optionText,
            isSelected: isSelected,
            isSmallScreen: isSmallScreen,
            showLetter: true,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSinglechoiceOptions(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your answer (A or B):',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        ...currentQuestion!.options.entries.map((entry) {
          final optionKey = entry.key;
          final optionText = entry.value;
          final isSelected = currentQuestion?.selectedOption == optionKey;

          return _buildOptionTile(
            optionKey: optionKey,
            optionText: optionText,
            isSelected: isSelected,
            isSmallScreen: isSmallScreen,
            showLetter: true,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTrueFalseOptions(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select True or False:',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        ...currentQuestion!.options.entries.map((entry) {
          final optionKey = entry.key;
          final optionText = entry.value;
          final isSelected = currentQuestion?.selectedOption == optionKey;

          return _buildOptionTile(
            optionKey: optionKey,
            optionText: optionText,
            isSelected: isSelected,
            isSmallScreen: isSmallScreen,
            showLetter: false,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDescriptiveInput(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Write your answer:',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        Container(
          constraints: BoxConstraints(minHeight: 120, maxHeight: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _descriptiveController,
            focusNode: _descriptiveFocusNode,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText:
                  'Enter your answer here...\n\nYou can write multiple lines.\nTap and hold to select text.',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              alignLabelWithHint: true,
            ),
            onChanged: (value) {
              saveResponses(currentQuestion!, descriptiveAnswer: value);
            },
            onTap: () {
              // Ensure the text field is visible when tapped
              Future.delayed(Duration(milliseconds: 300), () {
                Scrollable.ensureVisible(
                  context,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            },
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Tip: You can scroll up/down to see more content when typing',
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required String optionKey,
    required String optionText,
    required bool isSelected,
    required bool isSmallScreen,
    required bool showLetter,
  }) {
    String displayText = optionText;
    if (showLetter) {
      displayText =
          '${optionKey.toUpperCase().replaceAll('OPT_', '')}. $optionText';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            final newSelectedOption = isSelected ? null : optionKey;
            setState(() {
              currentQuestion = currentQuestion?.copyWith(
                selectedOption: newSelectedOption,
              );
            });
            saveResponses(currentQuestion!, selectedOption: newSelectedOption);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected ? Colors.blue : Colors.transparent,
                  ),
                  child:
                      isSelected
                          ? Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: isSelected ? Colors.blue[700] : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
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

  Widget _buildTopSection(bool isSmallScreen) {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timer
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      _secondsRemaining < 300
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _secondsRemaining < 300 ? Colors.red : Colors.green,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color:
                          _secondsRemaining < 300 ? Colors.red : Colors.green,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '$minutes:$seconds',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color:
                            _secondsRemaining < 300 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Progress indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  '${currentQuestionIndex + 1}/${questions.length}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Progress bar
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),

          SizedBox(height: 12),

          // Answered questions indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Answered: ${questions.where((q) => q.isAnswered).length}/${questions.length}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
              if (questions.where((q) => !q.isAnswered).isNotEmpty)
                Text(
                  '${questions.where((q) => !q.isAnswered).length} unanswered',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),

          SizedBox(height: 12),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  isSubmitting ? null : () => _showConfirmationDialog(false),
              icon:
                  isSubmitting
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Icon(Icons.send),
              label: Text(
                isSubmitting ? 'Submitting...' : 'Submit Exam',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    currentQuestionIndex == 0 ? Colors.grey : Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed:
                  currentQuestionIndex > 0 ? _navigateToPreviousQuestion : null,
              icon: Icon(Icons.arrow_back, size: 16),
              label: Text(
                'Previous',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
            ),
          ),

          SizedBox(width: 16),

          // Next/Submit button
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    currentQuestionIndex == questions.length - 1
                        ? Colors.green
                        : Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (currentQuestionIndex < questions.length - 1) {
                  _navigateToNextQuestion();
                } else {
                  _showConfirmationDialog(false);
                }
              },
              icon: Icon(
                currentQuestionIndex == questions.length - 1
                    ? Icons.send
                    : Icons.arrow_forward,
                size: 16,
              ),
              label: Text(
                currentQuestionIndex == questions.length - 1
                    ? 'Submit'
                    : 'Next',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPreviousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        currentQuestion = questions[currentQuestionIndex];
        _descriptiveController.text = currentQuestion?.descriptiveAnswer ?? '';
      }
    });
  }

  Color _getQuestionTypeColor() {
    switch (currentQuestion?.type) {
      case QuestionType.multichoice:
        return Colors.blue;
      case QuestionType.singlechoice:
        return Colors.purple;
      case QuestionType.true_false:
        return Colors.orange;
      case QuestionType.descriptive:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getQuestionTypeText() {
    switch (currentQuestion?.type) {
      case QuestionType.multichoice:
        return 'Multiple Choice';
      case QuestionType.singlechoice:
        return 'Single Choice';
      case QuestionType.true_false:
        return 'True/False';
      case QuestionType.descriptive:
        return 'Descriptive';
      default:
        return 'Question';
    }
  }
}
