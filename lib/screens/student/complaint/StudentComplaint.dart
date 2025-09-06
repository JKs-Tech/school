import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/controller/system_controller.dart';
import 'package:infixedu/screens/student/complaint/ComplaintData.dart';
import 'package:infixedu/screens/student/complaint/StudentAddComplaintScreen.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentComplaint extends StatefulWidget {
  const StudentComplaint({super.key});

  @override
  _StudentComplaintState createState() => _StudentComplaintState();
}

class _StudentComplaintState extends State<StudentComplaint> {
  List<ComplaintData> complaintList = [];
  bool isLoading = false;
  String _token = '', _id = '';
  int _studentId = 0;

  @override
  void initState() {
    super.initState();
    if (isStudent()) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomScreenAppBarWidget(
        title: 'Complaint',
        rightWidget: [
          IconButton(
            onPressed: () {
              loadData();
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
        child:
            isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(radius: 20),
                      SizedBox(height: 16),
                      Text(
                        'Loading complaints...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : complaintList.isEmpty
                ? _buildEmptyState()
                : _buildComplaintList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentAddComplaintScreen(),
            ),
          );
          if (result == true) {
            // Reload complaints when the add complaint screen is closed
            loadData();
          }
        },
        icon: Icon(Icons.add),
        label: Text(
          'New Complaint',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 2,
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
              Icons.report_problem_outlined,
              size: 60,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No Complaints Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You haven\'t submitted any complaints.\nTap the button below to create your first complaint.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: complaintList.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          return StudentComplaintCard(complaintData: complaintList[index]);
        },
      ),
    );
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'user_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    print('complaint params = $params');
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getComplaintListUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      print('complaint response = ${response.body}');
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey("complaint")) {
          List<dynamic> complaintArray =
              responseData["complaint"]["complaints"];
          List<ComplaintData> tempComplaintList =
              complaintArray
                  .map((item) => ComplaintData.fromJson(item))
                  .toList();
          setState(() {
            complaintList.clear();
            complaintList.addAll(tempComplaintList.reversed.toList());
            isLoading = false;
          });
          saveComplaintCache();
        }
      } else {}
    } catch (e) {
      print('student complaint error = $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void saveComplaintCache() {
    // Implement local storage logic to save complaintList
    // For example, you can use shared_preferences or sqflite plugin
    // For the sake of simplicity, let's assume you have saved it already
  }
}

class StudentAddComplaint extends StatelessWidget {
  const StudentAddComplaint({super.key});

  @override
  Widget build(BuildContext context) {
    // Implement the UI for adding complaints
    // For example, you can use a form to input complaint details
    return Scaffold(
      appBar: AppBar(title: Text('Add Complaint')),
      body: Center(child: Text('Add Complaint Form')),
    );
  }
}

class StudentComplaintCard extends StatelessWidget {
  final ComplaintData complaintData;

  const StudentComplaintCard({super.key, required this.complaintData});

  String _getStatusText(String? actionTaken) {
    if (actionTaken == null ||
        actionTaken.isEmpty ||
        actionTaken.toLowerCase() == 'null') {
      return 'Pending';
    }
    return 'Resolved';
  }

  Color _getStatusColor(String? actionTaken) {
    if (actionTaken == null ||
        actionTaken.isEmpty ||
        actionTaken.toLowerCase() == 'null') {
      return Colors.orange;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final status = _getStatusText(complaintData.actionTaken);
    final statusColor = _getStatusColor(complaintData.actionTaken);

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
                    Icons.report_problem_outlined,
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
                        complaintData.complaintType ?? 'Unknown Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        complaintData.date ?? 'No date',
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
            if (complaintData.description?.isNotEmpty ?? false) ...[
              _buildInfoSection(
                'Description',
                complaintData.description!,
                Icons.description_outlined,
              ),
              SizedBox(height: 12),
            ],

            // Action Taken Section (only if not empty)
            if ((complaintData.actionTaken?.isNotEmpty ?? false) &&
                (complaintData.actionTaken != null &&
                    complaintData.actionTaken!.toLowerCase() != 'null')) ...[
              _buildInfoSection(
                'Action Taken',
                complaintData.actionTaken!,
                Icons.check_circle_outline,
                color: Colors.green,
              ),
              SizedBox(height: 12),
            ],

            // Additional Info Row
            Row(
              children: [
                if ((complaintData.assigned?.isNotEmpty ?? false) &&
                    complaintData.assigned != null &&
                    complaintData.assigned!.toLowerCase() != 'null')
                  Expanded(
                    child: _buildInfoChip(
                      'Assigned',
                      complaintData.assigned!,
                      Icons.person_outline,
                    ),
                  ),
                if ((complaintData.assigned?.isNotEmpty ?? false) &&
                    complaintData.assigned != null &&
                    complaintData.assigned!.toLowerCase() != 'null' &&
                    (complaintData.note?.isNotEmpty ?? false) &&
                    complaintData.note != null &&
                    complaintData.note!.toLowerCase() != 'null')
                  SizedBox(width: 8),
                if ((complaintData.note?.isNotEmpty ?? false) &&
                    complaintData.note != null &&
                    complaintData.note!.toLowerCase() != 'null')
                  Expanded(
                    child: _buildInfoChip(
                      'Note',
                      complaintData.note!,
                      Icons.note_outlined,
                    ),
                  ),
              ],
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
            status == 'Pending' ? Icons.access_time : Icons.check_circle,
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

  Widget _buildInfoSection(
    String title,
    String content,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: (color ?? Colors.grey).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color ?? Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color ?? Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String title, String content, IconData icon) {
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
                title,
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
            content,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
