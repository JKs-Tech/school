import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/controller/system_controller.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class AboutSchool extends StatefulWidget {
  const AboutSchool({super.key});

  @override
  _AboutSchoolState createState() => _AboutSchoolState();
}

class _AboutSchoolState extends State<AboutSchool> {
  String name = '',
      address = '',
      email = '',
      phone = '',
      schoolCode = '',
      currentSession = '',
      sessionStartMonth = '',
      logoUrl = '',
      _token = '',
      _id = '';

  int _studentId = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (isStudent()) {
      Utils.getStringValue('token').then((value) {
        _token = value;
      });
      Utils.getIntValue('studentId').then((value) {
        _studentId = value;
      });
      Utils.getStringValue('id').then((idValue) {
        setState(() {
          _id = idValue;
          getDataFromApi();
        });
      });
    }
  }

  void getDataFromApi() async {
    Map params = {
      'student_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getSchoolDetails()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      print('about response = ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          name = data['name'];
          email = data['email'];
          phone = data['phone'];
          address = data['address'];
          schoolCode = data['dise_code'];
          currentSession = data['session'];
          sessionStartMonth = data['start_month_name'];
          logoUrl =
              '${AppConfig.domainNameNew}/uploads/school_content/logo/' +
              data['image'];
        });
      } else {}
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'About School'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Image.network(
                                  logoUrl,
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildInfoRow('Address:', address),
                                    buildInfoRow('Phone:', phone),
                                    buildInfoRow('Email:', email),
                                    buildInfoRow('School Code:', schoolCode),
                                    buildInfoRow(
                                      'Current Session:',
                                      currentSession,
                                    ),
                                    buildInfoRow(
                                      'Session Start Month:',
                                      sessionStartMonth,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
  }
}
