// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/model/UserNotifications.dart';

class NotificationController extends GetxController {
  final Rx<String> _token = "".obs;

  Rx<String> get token => _token;

  final Rx<String> _id = "".obs;

  Rx<String> get id => _id;

  final Rx<int> _studentId = 0.obs;

  Rx<int> get studentId => _studentId;

  final Rx<String> _role = "".obs;

  Rx<String> get role => _role;

  Rx<UserNotificationList> userNotificationList = UserNotificationList().obs;

  Rx<bool> isLoading = false.obs;

  Rx<int> notificationCount = 0.obs;

  // Future<UserNotificationList> getNotifications() async {
  //   await getIdToken();
  //   try {
  //     isLoading(true);
  //     Map params = {
  //       'student_id': _studentId.toString(),
  //       'type': _role.toString(),
  //       'schoolId': await Utils.getStringValue('schoolId')
  //     };
  //     var body = jsonEncode(params);
  //     final response = await http.post(
  //         Uri.parse(InfixApi.getMyNotifications(_id)),
  //         headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
  //         body: body);
  //     if (response.statusCode == 200) {
  //       var jsonData = jsonDecode(response.body);
  //       userNotificationList.value =
  //           UserNotificationList.fromJson(jsonData['data']['notifications']);
  //       notificationCount.value = jsonData['data']['unread_notification'];
  //       return userNotificationList.value;
  //     } else {
  //       isLoading(false);
  //       throw Exception('failed to load');
  //     }
  //   } catch (e) {
  //     isLoading(false);
  //     throw Exception(e.toString());
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  Future<UserNotificationList> getNotifications() async {
    await getIdToken();
    try {
      isLoading(true);
      Map params = {
        'student_id': _studentId.toString(),
        'type': _role.toString(),
        'schoolId': await Utils.getStringValue('schoolId'),
      };
      var body = jsonEncode(params);
      final response = await http.post(
        Uri.parse(InfixApi.getMyNotifications(_id)),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: body,
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        // Check if 'data' is a list
        if (jsonData['data'] is List) {
          userNotificationList.value = UserNotificationList.fromJson(
            jsonData['data'],
          );
        } else {
          throw Exception('Expected a list in "data" field');
        }

        // If unread_notification is needed, ensure it exists in the response
        // notificationCount.value = jsonData['data']['unread_notification'];

        return userNotificationList.value;
      } else {
        isLoading(false);
        throw Exception('Failed to load');
      }
    } catch (e) {
      isLoading(false);
      throw Exception(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future readNotification(int notificationId) async {
    await getIdToken();
    var response = await http.get(
      Uri.parse(InfixApi.readMyNotifications(_id.value, notificationId)),
      headers: Utils.setHeader(_token.toString()),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> notifications = Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
      bool status = notifications['data']['status'];
      return status;
    } else {
      debugPrint('Error retrieving from api');
    }
  }

  Future getIdToken() async {
    await Utils.getStringValue('token').then((value) async {
      _token.value = value;
      await Utils.getStringValue('id').then((value) {
        _id.value = value;
      });
      await Utils.getIntValue('studentId').then((value) {
        _studentId.value = value;
      });
      await Utils.getStringValue('role').then((value) {
        _role.value = value;
      });
    });
  }

  @override
  void onInit() {
    getNotifications();

    super.onInit();
  }
}

void printLongStringWithPrefixSuffix(
  String data, {
  String prefix = '----->',
  String suffix = '<-----',
  int chunkSize = 1000,
}) {
  // Add prefix and suffix to the entire string
  String wrappedString = '$prefix $data $suffix';

  // Split the string into chunks of `chunkSize` characters
  for (int i = 0; i < wrappedString.length; i += chunkSize) {
    int end =
        (i + chunkSize < wrappedString.length)
            ? i + chunkSize
            : wrappedString.length;
    String chunk = wrappedString.substring(i, end);
    print(chunk);
  }
}
