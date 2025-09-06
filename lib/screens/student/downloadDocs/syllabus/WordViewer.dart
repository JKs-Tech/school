import 'dart:io';

import 'package:flutter/material.dart';
import 'package:docx_viewer/docx_viewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:infixedu/utils/Utils.dart';

class WordViewerScreen extends StatefulWidget {
  final String title;
  final String fileUrl;

  const WordViewerScreen({
    super.key,
    required this.title,
    required this.fileUrl,
  });

  @override
  State<WordViewerScreen> createState() => _WordViewerScreenState();
}

class _WordViewerScreenState extends State<WordViewerScreen> {
  String? localFilePath;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    downloadAndSaveFile();
  }

  Future<void> downloadAndSaveFile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Download the file
      final response = await http.get(Uri.parse(widget.fileUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file');
      }

      // Get application documents directory
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      // Create a file name
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.docx';
      String filePath = '$appDocPath/$fileName';

      // Save the file
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        localFilePath = filePath;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error downloading file: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading Word document...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Unable to load document',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: downloadAndSaveFile,
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
              : localFilePath != null
              ? Padding(
                padding: EdgeInsets.all(16),
                child: DocxView(
                  filePath: localFilePath!,
                  fontSize: 14,
                  onError: (error) {
                    setState(() {
                      errorMessage = error.toString();
                    });
                  },
                ),
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No document available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    // Clean up downloaded file
    if (localFilePath != null) {
      File(localFilePath!).delete().catchError((e) {
        // Ignore errors when deleting temp files
        return File('');
      });
    }
    super.dispose();
  }
}
