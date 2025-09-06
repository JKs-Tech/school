import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/chat/views/FilePreview/ImagePreview.dart';
import 'package:infixedu/screens/student/downloadDocs/syllabus//Assignment.dart';
import 'package:infixedu/screens/student/downloadDocs/syllabus/ExcelViewer.dart';
import 'package:infixedu/screens/student/downloadDocs/syllabus/WordViewer.dart';
import 'package:infixedu/screens/student/studyMaterials/StudyMaterialViewer.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:path/path.dart' as Path;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class SyllabusScreen extends StatefulWidget {
  final String title;
  final String tag;

  const SyllabusScreen({super.key, required this.title, required this.tag});

  @override
  _SyllabusScreenState createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  List<Assignment> assignments = [];
  String _token = '', _id = '';
  bool isLoading = false;

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  Future<void> _initializeData() async {
    _token = await Utils.getStringValue('token');
    _id = await Utils.getStringValue('id');
    fetchDataFromApi();
  }

  Future<void> fetchDataFromApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      Map<String, String> params = {
        "tag": widget.tag,
        "classId": "",
        "sectionId": "",
        'schoolId': await Utils.getStringValue('schoolId'),
      };
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getDownloadsLinksUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      print('docs map = $params');
      print('docs response = ${response.body}');
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        print('docs jsonResponse = $jsonResponse');
        if (jsonResponse["success"] == 1) {
          List<dynamic> dataArray = jsonResponse["data"];
          assignments =
              dataArray.map((data) => Assignment.fromJson(data)).toList();
          print('docs assignments = $assignments');
        }
      } else {}
    } catch (e) {
      print('syllabus error = ${e.toString()}');
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
      appBar: CustomScreenAppBarWidget(title: widget.title),
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
                        'Loading ${widget.title}...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : assignments.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.description,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'No ${widget.title} Available',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check back later for updates',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: fetchDataFromApi,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      return AssignmentCard(assignment: assignments[index]);
                    },
                  ),
                ),
      ),
    );
  }
}

class AssignmentCard extends StatefulWidget {
  final Assignment assignment;

  const AssignmentCard({super.key, required this.assignment});

  @override
  State<AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<AssignmentCard> {
  String fileName = "", fileUrl = '';
  bool isPDF = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    if (widget.assignment.hasFile) {
      fileUrl = await InfixApi.getImageUrl() + widget.assignment.file!;
      fileName = Path.basename(fileUrl);
      isPDF = widget.assignment.isPDF;
    }
    setState(() {});
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      // Parse the date assuming it's in dd/MM/yyyy format
      DateFormat inputFormat = DateFormat('dd/MM/yyyy');
      DateTime date = inputFormat.parse(dateString);

      DateTime now = DateTime.now();
      Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  IconData _getFileIcon() {
    if (widget.assignment.isPDF) {
      return Icons.picture_as_pdf;
    } else if (widget.assignment.isImage) {
      return Icons.image;
    } else if (widget.assignment.isDocument) {
      return Icons.description;
    } else if (widget.assignment.isExcel) {
      return Icons.table_chart;
    } else {
      return Icons.attach_file;
    }
  }

  Color _getFileIconColor() {
    if (widget.assignment.isPDF) {
      return Colors.red[600]!;
    } else if (widget.assignment.isImage) {
      return Colors.green[600]!;
    } else if (widget.assignment.isDocument) {
      return Colors.blue[600]!;
    } else if (widget.assignment.isExcel) {
      return Colors.teal[600]!;
    } else {
      return Colors.grey[600]!;
    }
  }

  Future<void> _handleFileOpen(BuildContext context) async {
    if (widget.assignment.isPDF) {
      // Open PDF in built-in viewer
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => DownloadViewer(
                title: widget.assignment.displayTitle,
                filePath: fileUrl,
              ),
        ),
      );
    } else if (widget.assignment.isImage) {
      // Open images in image preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ImagePreviewPage(
                imageUrl: fileUrl,
                title: widget.assignment.displayTitle,
              ),
        ),
      );
    } else if (widget.assignment.isExcel) {
      // Open Excel files in in-app Excel viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ExcelViewerScreen(
                title: widget.assignment.displayTitle,
                fileUrl: fileUrl,
              ),
        ),
      );
    } else if (widget.assignment.isDocument) {
      // Open Word documents in in-app Word viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => WordViewerScreen(
                title: widget.assignment.displayTitle,
                fileUrl: fileUrl,
              ),
        ),
      );
    } else {
      // For other file types, try to open with default app as fallback
      await _downloadAndOpenFile(context);
    }
  }

  Future<void> _downloadAndOpenFile(BuildContext context) async {
    try {
      // Show loading indicator
      Utils.showToast('Downloading ${widget.assignment.displayTitle}...');

      // Get application documents directory
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      // Create a proper file name with extension
      String fileName =
          widget.assignment.displayTitle.replaceAll(RegExp(r'[^\w\s-.]'), '') +
          (widget.assignment.fileExtension.isNotEmpty
              ? '.${widget.assignment.fileExtension}'
              : '');
      String savePath = '$appDocPath/$fileName';

      // Download the file
      Dio dio = Dio();
      await dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total * 100);
            if (progress % 20 == 0) {
              // Show progress every 20%
              Utils.showToast('Downloading... ${progress.toStringAsFixed(0)}%');
            }
          }
        },
      );

      Utils.showToast('Download completed. Opening file...');

      // Open the file with system default app
      OpenResult result = await OpenFilex.open(savePath);

      if (result.type != ResultType.done) {
        Utils.showToast('Unable to open file. File saved to: $fileName');
      }
    } catch (e) {
      // If opening fails, show error message
      Utils.showToast('Unable to download or open file. Please try again.');
      print('Error downloading/opening file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.grey.withValues(alpha: 0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _handleFileOpen(context);
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getFileIconColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getFileIcon(),
                        color: _getFileIconColor(),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.assignment.displayTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 4),
                              Text(
                                _formatDate(widget.assignment.displayDate),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (fileName.isNotEmpty) ...[
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  size: 16,
                                  color: Colors.grey[500],
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    fileName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                if (widget.assignment.hasNote) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
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
                            Icon(Icons.note, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 6),
                            Text(
                              'Note',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.assignment.displayNote,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
