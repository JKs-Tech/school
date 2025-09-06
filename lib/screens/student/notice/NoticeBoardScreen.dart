import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentNoticeBoard extends StatefulWidget {
  const StudentNoticeBoard({super.key});

  @override
  _StudentNoticeBoardState createState() => _StudentNoticeBoardState();
}

class _StudentNoticeBoardState extends State<StudentNoticeBoard> {
  List<String> noticeTitleId = [];
  List<String> noticeTitleList = [];
  List<String> noticeDateList = [];
  List<String> noticeDescList = [];
  String _token = '', _id = '', _role = '';
  int _studentId = 0;
  bool isLoading = false;

  @override
  void initState() {
    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getIntValue('studentId').then((value) {
      _studentId = value;
    });
    Utils.getStringValue('role').then((value) {
      _role = value;
    });
    Utils.getStringValue('id').then((idValue) {
      setState(() {
        _id = idValue;
        fetchNotifications();
      });
    });
    super.initState();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });
    try {
      final params = {
        'type': _role,
        'student_id': _studentId.toString(),
        'schoolId': await Utils.getStringValue('schoolId'),
      };
      print("notice board params = $params");
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getNotificationsUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );
      print("notice board response = $response");
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print("notice board jsonData = $jsonData");
        if (jsonData['success'] == 1) {
          final dataArray = jsonData['data'];

          for (var data in dataArray) {
            noticeTitleId.add(data['id']);
            noticeTitleList.add(data['title']);
            noticeDateList.add(
              Utils.parseDate("yyyy-MM-dd", "dd/MM/yyyy", data['date']),
            );
            noticeDescList.add(data['message']);
          }

          setState(() {});
        }
      }
    } catch (e) {
      print('Notice board screen error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Notice Board'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : noticeTitleList.isEmpty
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
                    itemCount: noticeTitleList.length,
                    itemBuilder: (context, index) {
                      return StudentNotificationAdapter(
                        title: noticeTitleList[index],
                        date: noticeDateList[index],
                        onViewPressed: () {
                          _showBottomSheet(context, index);
                        },
                      );
                    },
                  ),
                ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, int position) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _buildBottomSheetContent(context, position);
      },
    );
  }

  Widget _buildBottomSheetContent(BuildContext context, int position) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              noticeTitleList[position],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(noticeDescList[position], style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 16.0),
            if (noticeDescList[position].startsWith("https"))
              ElevatedButton(
                onPressed: () {
                  _openUrl(context, noticeDescList[position]);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Set button background color here
                  foregroundColor: Colors.white, // Set text color here
                ),
                child: Text('Open URL'),
              ),
          ],
        ),
      ),
    );
  }

  void _openUrl(BuildContext context, String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        // If the URL can't be opened, handle the situation here
        // For example, you can navigate to another screen to show the content.
      }
    } catch (e) {
      // Handle any exceptions that might occur while trying to open the URL
    }
  }
}

class StudentNotificationAdapter extends StatelessWidget {
  final String title;
  final String date;
  final VoidCallback onViewPressed;

  const StudentNotificationAdapter({
    super.key,
    required this.title,
    required this.date,
    required this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Text(
                  'Date:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 10.0),
                Text(
                  date,
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                ),
                Spacer(),
                InkWell(
                  onTap: onViewPressed,
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 24.0, color: Colors.blue),
                      SizedBox(width: 5.0),
                      Text(
                        'View',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
