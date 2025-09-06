import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/liveClasses/LiveClassScreen.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentLiveClasses extends StatefulWidget {
  const StudentLiveClasses({super.key});

  @override
  _StudentLiveClassesState createState() => _StudentLiveClassesState();
}

class _StudentLiveClassesState extends State<StudentLiveClasses> {
  List<String> titleList = [];
  List<String> dateList = [];
  List<String> classList = [];
  List<String> idList = [];
  List<String> joinUrlList = [];
  List<String> statusList = [];
  String _token = '', _id = '';
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
    Utils.getStringValue('id').then((idValue) {
      setState(() {
        _id = idValue;
        loadData();
      });
    });
    super.initState();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'student_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getLiveClassesUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );
      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);
        List<dynamic> dataArray = jsonResult['live_classes'];

        titleList.clear();
        dateList.clear();
        classList.clear();
        idList.clear();
        joinUrlList.clear();
        statusList.clear();

        if (dataArray.isNotEmpty) {
          for (var item in dataArray) {
            titleList.add(item['title']);
            dateList.add(item['date']);
            classList.add('${item['class']} (${item['section']})');
            idList.add(item['id']);
            joinUrlList.add(item['join_url']);
            statusList.add(item['status']);
          }
        }
      }
    } catch (e) {
      print('student live classes error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkLiveClass(int position) async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'student_id': _studentId.toString(),
      'conference_id': idList[position],
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getLiveHistoryUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );
      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);
        Fluttertoast.showToast(msg: jsonResult['msg']);
      }
    } catch (e) {
      print('check live class error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveClassScreen(joinUrl: joinUrlList[position]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Live Classes'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : titleList.isEmpty
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
                    itemCount: titleList.length,
                    itemBuilder: (context, index) {
                      return StudentLiveClassItem(
                        title: titleList[index],
                        date: dateList[index],
                        classes: classList[index],
                        status: statusList[index],
                        joinUrl: joinUrlList[index],
                        checkClass: () {
                          checkLiveClass(index);
                        },
                      );
                    },
                  ),
                ),
      ),
    );
  }
}

class StudentLiveClassItem extends StatelessWidget {
  final String? title;
  final String? date;
  final String? classes;
  final String? status;
  final String? joinUrl;
  final VoidCallback? checkClass;

  const StudentLiveClassItem({
    super.key,
    this.title,
    this.date,
    this.classes,
    this.status,
    this.joinUrl,
    this.checkClass,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text(
                    title ?? "",
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color:
                        (status == '0')
                            ? Colors.blue
                            : (status == '2')
                            ? Colors.green
                            : Colors.red,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    (status == '0')
                        ? "Awaited"
                        : (status == '2')
                        ? "Finished"
                        : "Cancelled",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      date ?? "",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Class",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      classes ?? "",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (status == "0") SizedBox(height: 10),
            if (status == "0")
              GestureDetector(
                onTap: checkClass,
                child: Container(
                  width: 140,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/ic_view.png', // Replace with the actual image path
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Join class',
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
