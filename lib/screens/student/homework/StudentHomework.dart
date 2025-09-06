// Dart imports:
import 'dart:convert';
import 'dart:developer';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/StudentRecordWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/model/StudentHomework.dart';
import 'package:infixedu/utils/model/StudentRecord.dart';
import 'package:infixedu/utils/widget/Homework_row.dart';

// ignore: must_be_immutable
class StudentHomework extends StatefulWidget {
  String id;
  bool isBackIconVisible;

  StudentHomework({
    super.key,
    required this.id,
    required this.isBackIconVisible,
  });

  @override
  _StudentHomeworkState createState() => _StudentHomeworkState();
}

class _StudentHomeworkState extends State<StudentHomework> {
  Future<HomeworkResponse>? homeworks;
  String _token = '', _id = '', document_url = '', homework_file = '';
  int _studentId = 0;

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
        print(_id);
        homeworks = fetchHomework();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomScreenAppBarWidget(
        title: 'Homework',
        isBackIconVisible: widget.isBackIconVisible,
        rightWidget: [
          IconButton(
            onPressed: () {
              setState(() {
                homeworks = fetchHomework();
              });
            },
            icon: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.refresh, size: 20, color: Colors.white),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 20,
            vertical: isSmallScreen ? 16 : 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Record Selection
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: StudentRecordWidget(
                  onTap: (Record record) async {
                    homeworks = fetchHomework();
                  },
                ),
              ),
              SizedBox(height: 16),

              // Homework List
              Expanded(
                child: FutureBuilder<HomeworkResponse>(
                  future: homeworks,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CupertinoActivityIndicator(radius: 20),
                            SizedBox(height: 16),
                            Text(
                              'Loading homework...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      if (snapshot.hasData) {
                        if (snapshot.data?.homeworklist?.isNotEmpty ?? false) {
                          return ListView.separated(
                            separatorBuilder:
                                (context, index) => SizedBox(height: 12),
                            padding: EdgeInsets.symmetric(vertical: 8),
                            itemCount: snapshot.data?.homeworklist?.length ?? 0,
                            itemBuilder: (context, index) {
                              return ModernHomeworkCard(
                                homework:
                                    snapshot.data?.homeworklist?[index] ??
                                    Homeworklist(),
                                documentUrl: document_url,
                                homeworkFile: homework_file,
                                type: 'student',
                              );
                            },
                          );
                        } else {
                          return _buildEmptyState();
                        }
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CupertinoActivityIndicator(radius: 20),
                              SizedBox(height: 16),
                              Text(
                                'Loading homework...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 60,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No Homework Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'There are no homework assignments at the moment.\nCheck back later for new assignments.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<HomeworkResponse> fetchHomework() async {
    Map params = {
      'student_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    var body = jsonEncode(params);
    final response = await http.post(
      Uri.parse(await InfixApi.getApiUrl() + InfixApi.getStudenthomeWorksUrl()),
      headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
      body: body,
    );

    // print full body
    log('body=$body');
    log('header = ${Utils.setHeaderNew(_token.toString(), _id.toString())}');
    final apiUrl = await InfixApi.getApiUrl();
    final studentHomeworkUrl = InfixApi.getStudenthomeWorksUrl();
    log('url = ${apiUrl + studentHomeworkUrl}');
    log('response=${response.body}');
    log('params=$params');

    print('body=${response.body}');
    print('header = ${Utils.setHeaderNew(_token.toString(), _id.toString())}');
    print('response = ${response.body}');
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      document_url = jsonData["document_url"];
      homework_file = jsonData["homework_file"];
      return HomeworkResponse.fromJson(jsonData);
    } else {
      throw Exception('failed to load');
    }
  }
}

// Modern Homework Card Widget
class ModernHomeworkCard extends StatelessWidget {
  final Homeworklist homework;
  final String documentUrl;
  final String homeworkFile;
  final String type;

  const ModernHomeworkCard({
    super.key,
    required this.homework,
    required this.documentUrl,
    required this.homeworkFile,
    required this.type,
  });

  String _removeHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return htmlString;

    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }

  String _getStatusText() {
    // Determine homework status based on dates and completion
    final now = DateTime.now();
    final submissionDate = DateTime.tryParse(homework.submitDate ?? '');

    if (submissionDate != null && now.isAfter(submissionDate)) {
      return 'Overdue';
    } else if (submissionDate != null) {
      return 'Pending';
    }
    return 'Active';
  }

  Color _getStatusColor() {
    final status = _getStatusText();
    switch (status) {
      case 'Overdue':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final status = _getStatusText();
    final statusColor = _getStatusColor();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment_outlined,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homework.name ?? 'Unknown Subject',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        homework.section ?? 'No Class',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status, statusColor),
              ],
            ),

            SizedBox(height: 16),

            // Description Section
            if (homework.description?.isNotEmpty ?? false) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      _removeHtmlTags(homework.description ?? ''),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
            ],

            // Date Information Row
            if (isSmallScreen)
              // Stack dates vertically on small screens
              Column(
                children: [
                  _buildDateInfo(
                    'Created',
                    homework.homeworkDate,
                    Icons.schedule,
                  ),
                  SizedBox(height: 8),
                  _buildDateInfo(
                    'Submission',
                    homework.submitDate,
                    Icons.event,
                  ),
                ],
              )
            else
              // Side by side on larger screens
              Row(
                children: [
                  Expanded(
                    child: _buildDateInfo(
                      'Created',
                      homework.homeworkDate,
                      Icons.schedule,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildDateInfo(
                      'Submission',
                      homework.submitDate,
                      Icons.event,
                    ),
                  ),
                ],
              ),

            SizedBox(height: 16),

            // Action Button - Clean View Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showHomeworkDetailsDialog(
                    context,
                    homework,
                    documentUrl,
                    homeworkFile,
                    type,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_outlined, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'Overdue'
                ? Icons.warning
                : status == 'Pending'
                ? Icons.access_time
                : Icons.check_circle,
            size: 14,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String? date, IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            date ?? 'N/A',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showHomeworkDetailsDialog(
    BuildContext context,
    Homeworklist homework,
    String documentUrl,
    String homeworkFile,
    String type,
  ) {
    // Show the homework details using the same logic as StudentHomeworkRow
    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Homework Details'),
          content: Container(
            width: double.maxFinite,
            child: StudentHomeworkRow(
              homework: homework,
              documentUrl: documentUrl,
              homeworkFile: homeworkFile,
              type: type,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
