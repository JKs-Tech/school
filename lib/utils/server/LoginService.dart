// Flutter imports:
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/controller/system_controller.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class Login {
  final String email;
  final String password;
  final String schoolId;

  Login(this.email, this.password, this.schoolId);

  Future<http.Response?> getLogin(BuildContext context) async {
    try {
      var header = Utils.setHeaderNew('', '');
      var url = Uri.parse(InfixApi.login());
      var fcmToken = await FirebaseMessaging.instance.getToken();
      Map jsonData = {
        "username": email,
        "password": password,
        "schoolId": schoolId,
        "deviceToken": fcmToken,
      };
      var body = jsonEncode(jsonData);
      print(body);
      if (isStudent()) return await http.post(url, headers: header, body: body);
    } catch (e, t) {
      debugPrint(e.toString());
      debugPrint(t.toString());
    }
    return null;
  }
}
