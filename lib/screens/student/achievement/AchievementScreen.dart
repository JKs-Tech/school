import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class AchievementData {
  final String image;
  final String title;
  final String description;

  AchievementData({
    required this.image,
    required this.title,
    required this.description,
  });
}

class AchievementCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const AchievementCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Html(
                    data: description,
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        color: Colors.black.withAlpha(153),
                      ),
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementAdapter extends StatelessWidget {
  final List<AchievementData> items;

  const AchievementAdapter({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return AchievementCard(
          imageUrl: item.image,
          title: item.title,
          description: item.description,
        );
      },
    );
  }
}

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  _AchievementScreenState createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  List<AchievementData> achievementList = [];
  String _token = '', _id = '';
  int _studentId = 0;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Achievement'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : achievementList.isEmpty
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
                  child: _buildContent(),
                ),
      ),
    );
  }

  Widget _buildContent() {
    if (achievementList.isNotEmpty) {
      return AchievementAdapter(items: achievementList);
    } else {
      return Center(child: Text("No achievements found."));
    }
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
        List<dynamic> achievements = object["events"];
        achievementList.clear();
        if (achievements.isNotEmpty) {
          for (var achievementItem in achievements) {
            AchievementData data = AchievementData(
              title: achievementItem["title"],
              description: achievementItem['description'],
              image: achievementItem['feature_image'],
            );
            achievementList.add(data);
          }
          setState(() {});
        }
      } else {}
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
