import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:infixedu/screens/student/leave/LeaveApplication.dart';
import 'package:flutter/cupertino.dart';

class AddLeave extends StatefulWidget {
  final LeaveApplication
  leaveApplication; // leaveId=null for new entry and leaveId=<valid value> for edit
  const AddLeave({super.key, required this.leaveApplication});
  @override
  _AddLeaveState createState() => _AddLeaveState();
}

class _AddLeaveState extends State<AddLeave> {
  TextEditingController reasonController = TextEditingController();
  File? selectedFile;
  bool isFromDateSelected = false;
  bool isToDateSelected = false;
  bool isFileUploaded = false;
  bool isSubmitting = false;
  String? fileName;

  String? _token,
      _id,
      applyDateApi = DateFormat('yyyy-MM-dd').format(DateTime.now()),
      applyDate = DateFormat('dd-MM-yyyy').format(DateTime.now()),
      fromDate,
      fromDateApi,
      toDate,
      toDateApi;
  int? _studentId;
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context, String type) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.blue, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // button text color
              ),
            ),
          ),
          child: child ?? Container(),
        );
      },
    );

    if (picked != null) {
      String uiFormat = "dd-MM-yyyy";
      String apiFormat = "yyyy-MM-dd";
      String uiDateTime = DateFormat(uiFormat).format(picked);
      String apiDateTime = DateFormat(apiFormat).format(picked);

      setState(() {
        if (type == 'fromDate') {
          fromDate = uiDateTime;
          fromDateApi = apiDateTime;
          isFromDateSelected = true;
        } else if (type == 'toDate') {
          toDate = uiDateTime;
          toDateApi = apiDateTime;
          isToDateSelected = true;
        }
      });
    }
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path ?? "");
        fileName = basename(result.files.single.path ?? '');
        isFileUploaded = true;
      });
    }
  }

  Future<void> _uploadFile(BuildContext context) async {
    setState(() {
      isSubmitting = true;
    });
    try {
      String url =
          widget.leaveApplication.id == null
              ? await InfixApi.getApiUrl() + InfixApi.getAddLeaveUrl()
              : await InfixApi.getApiUrl() + InfixApi.updateLeaveUrl();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(
        Utils.setHeaderNew(_token.toString(), _id.toString()),
      );

      if (selectedFile != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            selectedFile!.readAsBytesSync(),
            filename: fileName,
            contentType: MediaType.parse(Utils.getMimeType(selectedFile!.path)),
          ),
        );
      } else {
        request.fields['file'] = '';
      }
      request.fields['apply_date'] = applyDateApi ?? '';
      request.fields['from_date'] = fromDateApi ?? '';
      request.fields['to_date'] = toDateApi ?? '';
      request.fields['reason'] = reasonController.text;
      if (widget.leaveApplication.id == null) {
        request.fields['student_id'] = _studentId.toString();
      } else {
        request.fields['id'] = widget.leaveApplication.id.toString();
      }
      request.fields['schoolId'] = await Utils.getStringValue('schoolId');
      var response = await request.send();
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg:
              widget.leaveApplication.id == null
                  ? 'Leave saved successfully'
                  : 'Update successfully',
        );
        Get.back(result: true);
      } else {
        Fluttertoast.showToast(msg: 'Error, Please try again!');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error occurred: $e');
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    String oldFormat = "MM/dd/yyyy";
    String newFormat = "yyyy-MM-dd";

    applyDate =
        widget.leaveApplication.appliedDate ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    applyDateApi =
        widget.leaveApplication.originalAppliedDate ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    toDate = widget.leaveApplication.toDate;
    toDateApi = widget.leaveApplication.originalToDate;
    isToDateSelected = true;

    fromDate = widget.leaveApplication.fromDate;
    fromDateApi = widget.leaveApplication.originalFromDate;
    isFromDateSelected = true;

    reasonController.text = widget.leaveApplication.reason ?? '';

    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getIntValue('studentId').then((value) {
      _studentId = value;
    });
    Utils.getStringValue('id').then((idValue) {
      setState(() {
        _id = idValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomScreenAppBarWidget(title: 'Add Leave'),
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child:
            isSubmitting
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(radius: 20),
                      SizedBox(height: 16),
                      Text(
                        'Submitting leave application...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    left: isSmallScreen ? 16.0 : 24.0,
                    right: isSmallScreen ? 16.0 : 24.0,
                    top: isSmallScreen ? 16.0 : 24.0,
                    bottom: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Apply Date Section
                      _buildSectionHeader('Application Date'),
                      SizedBox(height: 8),
                      _buildDateContainer(
                        applyDate ?? '',
                        Icons.calendar_today,
                        Colors.blue.withOpacity(0.1),
                        Colors.blue,
                        isReadOnly: true,
                      ),

                      SizedBox(height: 24),

                      // Date Range Section
                      _buildSectionHeader('Leave Duration'),
                      SizedBox(height: 8),

                      if (isSmallScreen)
                        // Stack dates vertically on small screens
                        Column(
                          children: [
                            _buildDateSelector(
                              context,
                              'fromDate',
                              fromDate,
                              'From Date',
                              Icons.calendar_month,
                            ),
                            SizedBox(height: 12),
                            _buildDateSelector(
                              context,
                              'toDate',
                              toDate,
                              'To Date',
                              Icons.calendar_month_outlined,
                            ),
                            SizedBox(height: 16),
                            _buildFileUploadSection(),
                          ],
                        )
                      else
                        // Side by side layout for larger screens
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildDateSelector(
                                context,
                                'fromDate',
                                fromDate,
                                'From Date',
                                Icons.calendar_month,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              flex: 5,
                              child: _buildDateSelector(
                                context,
                                'toDate',
                                toDate,
                                'To Date',
                                Icons.calendar_month_outlined,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(flex: 3, child: _buildFileUploadSection()),
                          ],
                        ),

                      SizedBox(height: 24),

                      // Reason Section
                      _buildSectionHeader('Reason for Leave'),
                      SizedBox(height: 8),
                      _buildReasonField(),

                      SizedBox(height: 32),

                      // Submit Button
                      _buildSubmitButton(),
                      SizedBox(height: 200.0),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildDateContainer(
    String text,
    IconData icon,
    Color bgColor,
    Color iconColor, {
    bool isReadOnly = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReadOnly ? Colors.grey[300]! : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isReadOnly ? Colors.grey[600] : Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String type,
    String? date,
    String placeholder,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _selectDate(context, type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                (date != null && date.isNotEmpty)
                    ? Colors.blue.withOpacity(0.5)
                    : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  (date != null && date.isNotEmpty)
                      ? Colors.blue
                      : Colors.grey[500],
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                (date != null && date.isNotEmpty) ? date : placeholder,
                style: TextStyle(
                  fontSize: 15,
                  color:
                      (date != null && date.isNotEmpty)
                          ? Colors.grey[800]
                          : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectFile,
            icon: Icon(
              isFileUploaded ? Icons.check_circle : Icons.attach_file,
              size: 18,
            ),
            label: Text(
              isFileUploaded ? 'Attached' : 'Attach',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFileUploaded ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ),
        if (isFileUploaded && fileName != null) ...[
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_present, color: Colors.green, size: 16),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    fileName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReasonField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: TextField(
        controller: reasonController,
        decoration: InputDecoration(
          hintText: 'Please provide detailed reason for your leave...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
        minLines: 4,
        maxLines: 6,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 52,
      child: Builder(
        builder:
            (context) => ElevatedButton(
              onPressed: () {
                if (applyDateApi == null ||
                    !isFromDateSelected ||
                    !isToDateSelected ||
                    reasonController.text.trim().isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'From date, to date and reason should not be empty',
                  );
                  return;
                }
                if (!isSubmitting) {
                  _uploadFile(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.leaveApplication.id == null
                    ? 'Submit Leave Application'
                    : 'Update Leave Application',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
      ),
    );
  }
}
