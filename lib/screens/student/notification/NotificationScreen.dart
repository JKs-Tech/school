import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class NotificationBanner {
  final String title;
  final String description;
  final String featureImage;
  final String url;
  final String date;

  NotificationBanner({
    required this.title,
    required this.description,
    required this.featureImage,
    required this.url,
    required this.date,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationBanner> noticeList = [];
  String _token = '', _id = '';
  int _studentId = 0;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'News'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : noticeList.isEmpty
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
                    itemCount: noticeList.length,
                    itemBuilder: (context, index) {
                      return NotificationBannerAdapter(
                        notice: noticeList[index],
                      );
                    },
                  ),
                ),
      ),
    );
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> params = {
      "student_id": _studentId.toString(),
      "date_from": Utils.getDateOfMonth(DateTime.now(), "first"),
      "date_to": Utils.getDateOfMonth(DateTime.now(), "last"),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getDashBoardUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        final result = response.body;
        Map<String, dynamic> object = json.decode(result);
        List<dynamic> notices = object["notice"];
        noticeList.clear();
        if (notices.isNotEmpty) {
          for (var noticeItem in notices) {
            NotificationBanner data = NotificationBanner(
              featureImage: noticeItem['feature_image'],
              title: noticeItem["title"],
              description: noticeItem['description'],
              url: noticeItem['url'],
              date: noticeItem['date'],
            );
            noticeList.add(data);
          }
          setState(() {});
        }
      }
    } catch (e) {
      print('Notification screen  = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
        loadData();
      });
    });
    super.initState();
  }
}

class NotificationBannerAdapter extends StatelessWidget {
  final NotificationBanner notice;

  const NotificationBannerAdapter({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    notice.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  notice.date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          if (notice.featureImage.isNotEmpty)
            CachedNetworkImage(
              imageUrl: notice.featureImage,
              placeholder:
                  (context, url) => Image.asset('assets/placeholder_image.png'),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
              height: 200,
            )
          else
            Image.asset(
              'assets/ic_image_box.png',
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Html(
              data: notice.description,
              style: {
                "body": Style(
                  fontSize: FontSize(16),
                  color: Colors.black.withAlpha(153),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
