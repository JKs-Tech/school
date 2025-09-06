import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/chat/views/FilePreview/ImagePreview.dart';
import 'package:infixedu/screens/student/studyMaterials/StudyMaterialViewer.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:path/path.dart' as Path;

class StudentDocumentsScreen extends StatefulWidget {
  const StudentDocumentsScreen({super.key});

  @override
  _StudentDocumentsScreenState createState() => _StudentDocumentsScreenState();
}

class _StudentDocumentsScreenState extends State<StudentDocumentsScreen> {
  String _token = '', _id = '';
  int _studentId = 0;
  bool isLoading = false;
  List<Map<String, dynamic>> docList = [];
  String documentPath = '';

  void updateUIOnDownloadComplete(int index) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await _loadTokenAndId();
    documentPath = "uploads/student_documents/";
    fetchData();
  }

  Future<void> _loadTokenAndId() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> params = {
      'student_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getDocumentUrl()),
        headers: Utils.setHeaderNew(_token, _id),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          docList = data.cast<Map<String, dynamic>>();
        } else {
          print('document No documents available!');
        }
      } else {}
    } catch (e) {
      print('document error ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'My Documents'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : docList.isEmpty
                ? Center(
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
                )
                : Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ListView.builder(
                    itemCount: docList.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = docList[index];
                      return TileList(
                        fileUrl: InfixApi.rootNew + documentPath + data['doc'],
                        title: data['title'],
                      );
                    },
                  ),
                ),
      ),
    );
  }
}

class TileList extends StatefulWidget {
  const TileList({super.key, required this.fileUrl, required this.title});

  final String fileUrl;
  final String title;

  @override
  State<TileList> createState() => _TileListState();
}

class _TileListState extends State<TileList> {
  String fileName = "";

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    setState(() {
      fileName = Path.basename(widget.fileUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (fileName.toLowerCase().endsWith('.pdf')) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => DownloadViewer(
                    title: widget.title,
                    filePath: widget.fileUrl,
                  ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ImagePreviewPage(
                    imageUrl: widget.fileUrl,
                    title: widget.title,
                  ),
            ),
          );
        }
      },
      child: Card(
        elevation: 10,
        shadowColor: Colors.grey.shade100,
        child: ListTile(
          title: Text(widget.title),
          leading: Visibility(
            visible: true,
            child: Icon(Icons.file_copy_rounded),
          ),
        ),
      ),
    );
  }
}
