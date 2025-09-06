// Dart imports:
import 'dart:io';

import 'package:file_picker/file_picker.dart';
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
// Project imports:
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/model/StudentHomework.dart';
import 'package:path/path.dart';

class UploadHomework extends StatefulWidget {
  final Homeworklist homework;
  final String userID;

  const UploadHomework({
    super.key,
    required this.homework,
    required this.userID,
  });

  @override
  _UploadHomeworkState createState() => _UploadHomeworkState();
}

class _UploadHomeworkState extends State<UploadHomework>
    with TickerProviderStateMixin {
  String _token = '', _id = '', fileName = '';
  bool isResponse = false;
  File? selectedFile;
  TextEditingController descriptionController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();

    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getStringValue('id').then((value) {
      _id = value;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );
      if (result != null) {
        setState(() {
          selectedFile = File(result.files.single.path!);
          fileName = basename(result.files.single.path!);
        });

        // Show success feedback
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('File selected successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Error selecting file: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _uploadFile(BuildContext context) async {
    if (descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a description');
      return;
    }

    if (selectedFile == null) {
      _showErrorSnackBar('Please select a file');
      return;
    }

    setState(() {
      isResponse = true;
    });

    try {
      String url = await InfixApi.getApiUrl() + InfixApi.getUploadHomeUrl();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(Utils.setHeaderNew(_token, _id));

      print('upload url = $url');
      print('upload selectedFile = $selectedFile');
      print('upload fileName = $fileName');

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          selectedFile!.readAsBytesSync(),
          filename: fileName,
          contentType: MediaType.parse(Utils.getMimeType(selectedFile!.path)),
        ),
      );
      request.fields['message'] = descriptionController.text.trim();
      request.fields['homework_id'] = widget.homework.id ?? '';
      request.fields['schoolId'] = await Utils.getStringValue('schoolId');
      request.fields['student_id'] =
          (await Utils.getIntValue('studentId')).toString();
      print('upload request = $request');
      var response = await request.send();
      print('upload response = $response');

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Homework uploaded successfully!');
        await Future.delayed(Duration(seconds: 1));
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        _showErrorSnackBar('Upload failed. Please try again!');
      }
    } catch (e) {
      _showErrorSnackBar('Error occurred: $e');
    } finally {
      setState(() {
        isResponse = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getFileSize(File file) {
    int bytes = file.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _getFileExtension(String fileName) {
    return fileName.split('.').last.toUpperCase();
  }

  Color _getFileTypeColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'txt':
        return Colors.grey;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[50]!, Colors.white],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 28,
                  vertical: isSmallScreen ? 20 : 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Header with Animation
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue, Colors.blue.shade600],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.cloud_upload_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload Homework',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Submit your completed assignment',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Description Field with Enhanced Design
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    descriptionController.text.isNotEmpty
                                        ? Colors.blue.withOpacity(0.5)
                                        : Colors.grey[300]!,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: descriptionController,
                              maxLines: 4,
                              onChanged: (value) => setState(() {}),
                              decoration: InputDecoration(
                                hintText:
                                    'Describe your homework submission, any notes, or questions...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Enhanced File Selection
                    Container(
                      margin: EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Homework File',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          InkWell(
                            onTap: isResponse ? null : _selectFile,
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color:
                                    selectedFile != null
                                        ? Colors.green.withOpacity(0.05)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      selectedFile != null
                                          ? Colors.green.withOpacity(0.5)
                                          : Colors.grey[300]!,
                                  width: selectedFile != null ? 2 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        selectedFile != null
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child:
                                  selectedFile == null
                                      ? Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.cloud_upload_outlined,
                                              color: Colors.blue,
                                              size: 32,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Tap to Select File',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'PDF, DOC, TXT, or Image files',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      )
                                      : Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: _getFileTypeColor(
                                                _getFileExtension(fileName),
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.insert_drive_file,
                                              color: _getFileTypeColor(
                                                _getFileExtension(fileName),
                                              ),
                                              size: 24,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  fileName,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[800],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _getFileTypeColor(
                                                              _getFileExtension(
                                                                fileName,
                                                              ),
                                                            ).withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        _getFileExtension(
                                                          fileName,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              _getFileTypeColor(
                                                                _getFileExtension(
                                                                  fileName,
                                                                ),
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      _getFileSize(
                                                        selectedFile!,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Enhanced Submit Button
                    Container(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed:
                              isResponse ? null : () => _uploadFile(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isResponse ? Colors.grey[400] : Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: isResponse ? 0 : 4,
                            shadowColor: Colors.blue.withOpacity(0.3),
                          ),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child:
                                isResponse
                                    ? Row(
                                      key: ValueKey('loading'),
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Uploading...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Row(
                                      key: ValueKey('submit'),
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Submit Homework',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                    ),

                    // Progress Bar
                    if (isResponse) ...[
                      SizedBox(height: 20),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Helper Tips
                    if (!isResponse) ...[
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 18,
                                  color: Colors.blue[700],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Tips for Success',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• Write a clear description of your work\n• Ensure your file is readable and complete\n• Double-check before submitting',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Add bottom padding for safe area
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
