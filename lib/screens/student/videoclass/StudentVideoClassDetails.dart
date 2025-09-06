import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/chat/views/FilePreview/ImagePreview.dart';
import 'package:infixedu/screens/student/studyMaterials/StudyMaterialViewer.dart';
import 'package:infixedu/screens/student/videoclass/StudentSubjectDetails.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/videoplayer/NativeVideoPlayerScreen.dart';
import 'package:infixedu/utils/videoplayer/YoutubeVideoPlayerScreen.dart';

class StudentVideoClassDetails extends StatefulWidget {
  final StudentSubjectDetails studentSubjectDetails;

  const StudentVideoClassDetails({
    super.key,
    required this.studentSubjectDetails,
  });

  @override
  _StudentVideoClassDetailsState createState() =>
      _StudentVideoClassDetailsState();
}

class _StudentVideoClassDetailsState extends State<StudentVideoClassDetails> {
  String? _token,
      _id,
      className,
      sectionName,
      fileName = "",
      filePath,
      storePath;
  bool isLoading = false, downloading = false, fileExists = false;
  Map<String, dynamic> data = {};
  double progress = 0;

  @override
  void initState() {
    super.initState();
    fetchTokenAndId();
  }

  Future<void> fetchTokenAndId() async {
    try {
      _token = await Utils.getStringValue('token');
      _id = await Utils.getStringValue('id');
      className = await Utils.getStringValue('className');
      sectionName = await Utils.getStringValue('sectionName');
      await fetchData();
    } catch (e) {
      showErrorSnackBar('Failed to fetch data');
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final params = {
      'subject_group_subject_id': widget.studentSubjectDetails.subjectId,
      'subject_group_class_sections_id': widget.studentSubjectDetails.sectionId,
      'time_from': widget.studentSubjectDetails.fromTime,
      'time_to': widget.studentSubjectDetails.toTime,
      'date': widget.studentSubjectDetails.date,
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getSyllabusItemUrl()),
        headers: Utils.setHeaderNew(_token ?? "", _id ?? ''),
        body: json.encode(params),
      );

      print('response = ${response.body}');
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body)['data'][0];
        setState(() {
          data = decodedData;
          fileName = data['attachment'];
        });
      } else {
        showErrorSnackBar('Failed to load data');
      }
    } catch (e) {
      showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showPresentationDialog(BuildContext context, String presentationLink) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Colors.blue, // Use your color here
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Presentation',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Html(
                    data: presentationLink,
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        color: Colors.black,
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showErrorSnackBar(String message) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text(message)),
    // );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  Widget buildInfoColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  Widget buildCard(String assetImagePath, String title, String dataKey) {
    return Visibility(
      visible: data[dataKey].isNotEmpty,
      child: Card(
        elevation: 5,
        child: GestureDetector(
          onTap: () async {
            if (dataKey == 'attachment') {
              String urlStr =
                  "${await InfixApi.getImageUrl()}uploads/syllabus_attachment/$fileName";
              if (fileName?.toLowerCase().endsWith('.pdf') ?? false) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => DownloadViewer(
                          title: 'Attachment',
                          filePath: urlStr,
                        ),
                  ),
                );
                Fluttertoast.showToast(
                  msg: 'PDF file is not supported',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ImagePreviewPage(
                          imageUrl: urlStr,
                          title: 'Attachment',
                        ),
                  ),
                );
              }
            } else if (dataKey == 'lacture_youtube_url') {
              String videoId = data[dataKey];
              if (videoId.startsWith("http") || videoId.startsWith("www")) {
                Uri uri = Uri.parse(videoId);
                videoId = uri.queryParameters['v'] ?? '';
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => YoutubeVideoPlayerScreen(videoId: videoId),
                ),
              );
            } else {
              String videoUrl = data[dataKey];
              if (!videoUrl.startsWith("http") && !videoUrl.startsWith("www")) {
                videoUrl =
                    "${await InfixApi.getImageUrl()}uploads/syllabus_attachment/lacture_video/$videoUrl";
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => NativeVideoPlayerScreen(videoPath: videoUrl),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Image.asset(assetImagePath, width: 36, height: 36),
                    Text(title, style: TextStyle(color: Colors.blue)),
                  ],
                ),
                dataKey == 'attachment' && downloading
                    ? Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: Colors.grey,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                        Text(
                          (progress * 100).toStringAsFixed(2),
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                    )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(
        title:
            '${widget.studentSubjectDetails.subjectName}(${widget.studentSubjectDetails.date})',
      ),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : data.isEmpty
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
                : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      showPresentationDialog(
                                        context,
                                        data['presentation'],
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/ic_view.png',
                                          width: 40,
                                          height: 30,
                                        ),
                                        Text(
                                          'Read Theory',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (data['attachment'].isNotEmpty)
                              buildCard(
                                'assets/images/ic_view_notes.jpg',
                                'View Notes',
                                'attachment',
                              ),
                            if (data['lacture_youtube_url'].isNotEmpty)
                              buildCard(
                                'assets/images/ic_youtube.png',
                                'YouTube',
                                'lacture_youtube_url',
                              ),
                            if (data['lacture_video'].isNotEmpty)
                              buildCard(
                                'assets/images/ic_start_video.png',
                                'Start Video',
                                'lacture_video',
                              ),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        buildInfoRow('Class: ', '$className-$sectionName'),
                        buildInfoRow(
                          'Subject: ',
                          widget.studentSubjectDetails.subjectName ?? '',
                        ),
                        buildInfoRow(
                          'Date: ',
                          widget.studentSubjectDetails.date ?? '',
                        ),
                        buildInfoRow('Lessons: ', data['lesson_name']),
                        buildInfoRow('Topics: ', data['topic_name']),
                        buildInfoRow('Subtopics: ', data['sub_topic']),
                        buildInfoColumn(
                          'General Objectives:',
                          data['general_objectives'],
                        ),
                        buildInfoColumn(
                          'Teaching Method:',
                          data['teaching_method'],
                        ),
                        buildInfoColumn(
                          'Previous Knowledge:',
                          data['previous_knowledge'],
                        ),
                        buildInfoColumn(
                          'Comprehensive Questions:',
                          data['comprehensive_questions'],
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
