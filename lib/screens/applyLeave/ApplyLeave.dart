import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/applyLeave/AddLeave.dart';
import 'package:infixedu/screens/chat/views/FilePreview/ImagePreview.dart';
import 'package:infixedu/screens/student/leave/LeaveApplication.dart';
import 'package:infixedu/screens/student/studyMaterials/StudyMaterialViewer.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:path/path.dart' as Path;

class ApplyLeave extends StatefulWidget {
  const ApplyLeave({super.key});

  @override
  _ApplyLeaveState createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  List<LeaveApplication> leaveList = [];
  String? defaultDateFormat = "dd/MM/yyyy", _token, _id;
  int? _studentId;
  bool isDataLoading = false;

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

  void loadData() async {
    setState(() {
      isDataLoading = true;
    });
    Map params = {
      'student_id': _studentId,
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getApplyLeaveListUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );
      print(
        "request apply leave = ${await InfixApi.getApiUrl() + InfixApi.getApplyLeaveListUrl()}",
      );
      print(
        "header apply leave = ${Utils.setHeaderNew(_token.toString(), _id.toString())}",
      );
      print("body apply leave = ${json.encode(params)}");
      print('response apply leave = ${response.body}');
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        List<dynamic> dataArray = result['result_array'];
        leaveList.clear();
        for (int i = 0; i < dataArray.length; i++) {
          leaveList.add(
            LeaveApplication(
              id: dataArray[i]['id'],
              name:
                  dataArray[i]['lastname'] != null
                      ? dataArray[i]['firstname'] +
                          " " +
                          dataArray[i]['lastname']
                      : dataArray[i]['firstname'],
              fromDate: Utils.parseDate(
                "yyyy-MM-dd",
                defaultDateFormat ?? "dd/MM/yyyy",
                dataArray[i]['from_date'],
              ),
              toDate: Utils.parseDate(
                "yyyy-MM-dd",
                defaultDateFormat ?? "dd/MM/yyyy",
                dataArray[i]['to_date'],
              ),
              status: dataArray[i]['status'],
              reason: dataArray[i]['reason'],
              appliedDate: Utils.parseDate(
                "yyyy-MM-dd",
                defaultDateFormat ?? "dd/MM/yyyy",
                dataArray[i]['apply_date'],
              ),
              docs: dataArray[i]['docs'],
              originalFromDate: dataArray[i]['from_date'],
              originalToDate: dataArray[i]['to_date'],
              originalAppliedDate: dataArray[i]['apply_date'],
            ),
          );
        }
      }
    } finally {
      setState(() {
        isDataLoading = false;
      });
    }
  }

  void _deleteItem(int position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                "Confirm Delete",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to delete this leave application? This action cannot be undone.",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                deleteLeave(leaveList[position]);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteLeave(LeaveApplication leaveApplication) async {
    setState(() {
      isDataLoading = true;
    });
    Map params = {
      'leave_id': leaveApplication.id,
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.deleteLeaveUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        Fluttertoast.showToast(msg: 'Successfully deleted!');
        loadData();
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to load data')),
        // );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(e.toString())),
      // );
    } finally {
      setState(() {
        isDataLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomScreenAppBarWidget(title: 'Apply Leave'),
      body: SafeArea(
        child:
            isDataLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(radius: 20),
                      SizedBox(height: 16),
                      Text(
                        'Loading leave applications...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : leaveList.isEmpty
                ? _buildEmptyState()
                : _buildLeaveList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () async {
          // final result = await Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder:
          //         (context) => AddLeave(leaveApplication: LeaveApplication()),
          //   ),
          // );
          // if (result == true) {
          //   loadData();
          // }

          Get.to(() => AddLeave(leaveApplication: LeaveApplication()))?.then((
            value,
          ) {
            if (value == true) {
              loadData();
            }
          });
        },
        icon: Icon(Icons.add),
        label: Text('New Leave', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 2,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no_data.png', width: 150, height: 150),
          SizedBox(height: 16),
          Text(
            'No Leave Applications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start by creating your first leave application',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: leaveList.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          return TileList(
            leaveApplication: leaveList[index],
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AddLeave(leaveApplication: leaveList[index]),
                ),
              );
              if (result == true) {
                loadData();
              }
            },
            onDelete: () {
              _deleteItem(index);
            },
          );
        },
      ),
    );
  }
}

class TileList extends StatefulWidget {
  final LeaveApplication leaveApplication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TileList({
    super.key,
    required this.leaveApplication,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TileList> createState() => _TileListState();
}

class _TileListState extends State<TileList> {
  String? fileName = "", documentPath, fileUrl;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    documentPath = "uploads/student_leavedocuments/";
    setState(() {
      if (widget.leaveApplication.docs?.isNotEmpty ?? false) {
        fileUrl =
            InfixApi.rootNew +
            documentPath! +
            (widget.leaveApplication.docs ?? '');
        fileName = Path.basename(fileUrl!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

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
            // Header row with date and actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Applied: ${widget.leaveApplication.appliedDate}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildStatusChip(),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                _buildActionButtons(isSmallScreen),
              ],
            ),

            SizedBox(height: 16),

            // Reason section
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
                  Text(
                    'Reason',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.leaveApplication.reason ?? 'No reason provided',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Date range
            Row(
              children: [
                Expanded(
                  child: _buildDateInfo(
                    'From',
                    widget.leaveApplication.fromDate,
                    Icons.play_arrow,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDateInfo(
                    'To',
                    widget.leaveApplication.toDate,
                    Icons.stop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final isApproved = widget.leaveApplication.status == '1';
    final isPending = widget.leaveApplication.status == '0';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            isApproved
                ? Colors.green.withOpacity(0.1)
                : isPending
                ? Colors.orange.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color:
              isApproved
                  ? Colors.green.withOpacity(0.3)
                  : isPending
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isApproved
                ? Icons.check_circle
                : isPending
                ? Icons.access_time
                : Icons.cancel,
            size: 12,
            color:
                isApproved
                    ? Colors.green[700]
                    : isPending
                    ? Colors.orange[700]
                    : Colors.red[700],
          ),
          SizedBox(width: 4),
          Text(
            isApproved
                ? 'Approved'
                : isPending
                ? 'Pending'
                : 'Rejected',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  isApproved
                      ? Colors.green[700]
                      : isPending
                      ? Colors.orange[700]
                      : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    List<Widget> buttons = [];

    // Document button
    if (widget.leaveApplication.docs?.isNotEmpty ?? false) {
      buttons.add(
        _buildActionButton(
          icon: Icons.file_present,
          color: Colors.blue,
          onTap: () {
            if (fileName!.toLowerCase().endsWith('.pdf')) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => DownloadViewer(
                        title: widget.leaveApplication.appliedDate ?? "",
                        filePath: fileUrl!,
                      ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ImagePreviewPage(
                        imageUrl: fileUrl!,
                        title: widget.leaveApplication.appliedDate ?? '',
                      ),
                ),
              );
            }
          },
        ),
      );
    }

    // Edit button (only for pending status)
    if (widget.leaveApplication.status == '0') {
      buttons.add(
        _buildActionButton(
          icon: Icons.edit_outlined,
          color: Colors.green,
          onTap: widget.onEdit,
        ),
      );
    }

    // Delete button (only for pending status)
    if (widget.leaveApplication.status == '0') {
      buttons.add(
        _buildActionButton(
          icon: Icons.delete_outline,
          color: Colors.red,
          onTap: widget.onDelete,
        ),
      );
    }

    if (isSmallScreen) {
      // For small screens, use dropdown menu to prevent overflow
      return PopupMenuButton<String>(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.more_vert, size: 18, color: Colors.grey[700]),
        ),
        onSelected: (value) {
          switch (value) {
            case 'document':
              if (fileName!.toLowerCase().endsWith('.pdf')) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => DownloadViewer(
                          title: widget.leaveApplication.appliedDate ?? "",
                          filePath: fileUrl!,
                        ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ImagePreviewPage(
                          imageUrl: fileUrl!,
                          title: widget.leaveApplication.appliedDate ?? '',
                        ),
                  ),
                );
              }
              break;
            case 'edit':
              widget.onEdit();
              break;
            case 'delete':
              widget.onDelete();
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          List<PopupMenuEntry<String>> items = [];

          if (widget.leaveApplication.docs?.isNotEmpty ?? false) {
            items.add(
              PopupMenuItem<String>(
                value: 'document',
                child: Row(
                  children: [
                    Icon(Icons.file_present, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('View Document'),
                  ],
                ),
              ),
            );
          }

          if (widget.leaveApplication.status == '0') {
            items.addAll([
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ]);
          }

          return items;
        },
      );
    } else {
      // For larger screens, show buttons in a row
      return Row(
        mainAxisSize: MainAxisSize.min,
        children:
            buttons
                .map(
                  (button) =>
                      Padding(padding: EdgeInsets.only(left: 4), child: button),
                )
                .toList(),
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 18, color: color),
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
}
