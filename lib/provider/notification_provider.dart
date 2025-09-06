// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/model/UserNotifications.dart';

class NotificationProvider extends ChangeNotifier {
  String? id;
  String? token, role;
  int? studentId;

  Future<UserNotificationList> getNotification(id, token) async {
    await Utils.getStringValue('token').then((value) async {
      token = value;
      await Utils.getStringValue('id').then((value) {
        id = value;
      });
      await Utils.getIntValue('studentId').then((value) {
        studentId = value;
      });
      await Utils.getStringValue('role').then((value) {
        role = value;
      });
    });
    Map params = {
      'student_id': studentId.toString(),
      'type': role.toString(),
      'schoolId': await Utils.getStringValue('schoolId')
    };

    var body = jsonEncode(params);
    final response = await http.post(Uri.parse(InfixApi.getMyNotifications(id)),
        headers: Utils.setHeaderNew(token.toString(), id.toString()),
        body: body);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return UserNotificationList.fromJson(jsonData['data']['notifications']);
    } else {
      throw Exception('failed to load');
    }
  }
}
