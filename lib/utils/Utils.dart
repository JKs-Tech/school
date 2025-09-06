// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:mime/mime.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Utils extends GetxController {
  static Future<bool> saveBooleanValue(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(key, value);
  }

  static Future<bool> saveStringValue(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(key, value);
  }

  static Future<bool> saveIntValue(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(key, value);
  }

  static Future<bool> getBooleanValue(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<bool> getBooleanValueWithoutDefault(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<String> getStringValue(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // print(prefs.getString(key));
    return prefs.getString(key) ?? '';
  }

  static Future<int> getIntValue(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    return prefs.getInt(key) ?? 0;
  }

  static Future<bool> clearAllValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  static Future<String> getTranslatedLanguage(
    String languageCode,
    String key,
  ) async {
    Map<dynamic, dynamic> localisedValues;
    String jsonContent = await rootBundle.loadString(
      "assets/locale/localization_$languageCode.json",
    );
    localisedValues = json.decode(jsonContent);
    return localisedValues[key] ?? key;
  }

  static setHeader(String token) {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };
    return header;
  }

  static setHeaderNew(String token, String userId) {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Client-Service': 'smartschool',
      'Auth-Key': 'schoolAdmin@',
      'Authorization': token,
      'User-ID': userId,
    };
    return header;
  }

  static setHeaderNew2() {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Client-Service': 'smartschool',
      'Auth-Key': 'schoolAdmin@',
    };
    return header;
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      textColor: Colors.white,
      backgroundColor: Colors.purple,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  static BoxDecoration gradientBtnDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(25.0),
    gradient: const LinearGradient(
      colors: [Color(0xff7C32FF), Color(0xffC738D8)],
    ),
  );

  static Text checkTextValue(text, value) {
    return Text("$text:: $value", style: const TextStyle(fontSize: 18));
  }

  static Widget noDataWidget() {
    return Center(
      child: Text(
        'No data available',
        style: Get.textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  static String getDateOfMonth(DateTime date, String index) {
    if (index == "first") {
      DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
      return DateFormat("yyyy-MM-dd").format(firstDayOfMonth);
    } else {
      DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
      return DateFormat("yyyy-MM-dd").format(lastDayOfMonth);
    }
  }

  static String parseDate(
    String originalFormat,
    String newFormat,
    String date,
  ) {
    String formattedDate;
    DateFormat targetFormat;
    DateFormat format = DateFormat(originalFormat, 'en_US');

    try {
      targetFormat = DateFormat(newFormat, 'en_US');
    } catch (e) {
      // Handle invalid date format
      newFormat = newFormat.replaceAll('Y', 'y');
      targetFormat = DateFormat(newFormat, 'en_US');
    }

    try {
      DateTime newDate = format.parse(date);
      formattedDate = targetFormat.format(newDate);
    } catch (e) {
      formattedDate = '';
    }

    return formattedDate;
  }

  static List<String> getComplaintType() {
    return [
      "FEES",
      "STUDY",
      "TEACHER",
      "SPORTS",
      "TRANSPORT",
      "DRIVER",
      "HOSTEL",
      "CLASS ROOM",
      "WEBSITE APP",
      "OTHER",
    ];
  }

  static List<String> getComplaintSources() {
    return ["FRONT OFFICE", "MARKETING", "SOCIAL MEDIA", "PUMPLET", "PHONE"];
  }

  static String formatDate(DateTime date, String format) {
    return DateFormat(format).format(date);
  }

  static Future<String> getDocumentsDirectoryPath() async {
    final appDocumentsDir = await getExternalStorageDirectory();
    return appDocumentsDir?.absolute.path ?? '';
  }

  static void openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      print('Open file result: ${result.type}');
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  static String getMimeType(String filePath) {
    final mimeType = lookupMimeType(filePath);
    return mimeType ?? 'application/octet-stream';
  }

  static String getTimeFormat(BuildContext context, int milliseconds) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    final hourFormat =
        MediaQuery.of(context).alwaysUse24HourFormat ? 'HH:mm' : 'hh:mm a';
    return DateFormat(hourFormat).format(dateTime);
  }

  static int getTimeMSFormat(String time) {
    try {
      DateTime parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(time);
      return parsedDate.millisecondsSinceEpoch;
    } catch (e) {
      print(e);
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  static String getTimeDataFormat(int timeInMillis) {
    final DateTime updateTime = DateTime.fromMillisecondsSinceEpoch(
      timeInMillis,
    );
    final DateTime now = DateTime.now();
    final DateTime todayMidnight = DateTime(now.year, now.month, now.day);
    final DateTime tomorrowMidnight = DateTime(
      now.year,
      now.month,
      now.day + 1,
    );
    final DateTime yestMidnight = DateTime(now.year, now.month, now.day - 1);

    if (updateTime.isAfter(todayMidnight) &&
        updateTime.isBefore(tomorrowMidnight)) {
      return "TODAY";
    } else if (updateTime.isAfter(yestMidnight) &&
        updateTime.isBefore(todayMidnight)) {
      return "YESTERDAY";
    } else {
      return DateFormat('MMM dd, yyyy').format(updateTime);
    }
  }

  static String getGMTFromLocal(int time) {
    try {
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US');
      final dateTime =
          DateTime.fromMillisecondsSinceEpoch(time).toUtc(); // Convert to UTC
      final gmtTime = dateFormat.format(dateTime);
      return gmtTime;
    } catch (e) {
      return time.toString();
    }
  }

  static Future<bool> isConnectedToInternet() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult.first == ConnectivityResult.mobile ||
        connectivityResult.first == ConnectivityResult.wifi ||
        connectivityResult.first == ConnectivityResult.ethernet;
  }
}
