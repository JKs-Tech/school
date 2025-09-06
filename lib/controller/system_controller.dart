import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/model/SystemSettings.dart';

class SystemController extends GetxController {
  Rx<SystemSettings> systemSettings = SystemSettings().obs;
  Rx<bool> isLoading = false.obs;

  final Rx<String> _token = "".obs;

  final Rx<String> _id = ''.obs;

  Rx<String> get id => _id;

  Rx<String> get token => _token;

  final Rx<String> _schoolId = "".obs;

  Rx<String> get schoolId => _schoolId;

  Future getSystemSettings() async {
    try {
      if (isStudent()) {
        isLoading(true);
        await getSchoolId().then((value) async {
          // Map params = {'schoolId': "1042"};
          // var body = jsonEncode(params);
          // final response = await http.post(
          //   Uri.parse('${AppConfig.domainNameNew}/api/webservice/appdetail'),
          //   headers: Utils.setHeaderNew("MTAMgNgMTA", "985"),
          //   body: body,
          // );

          print(
            "header = ${Utils.setHeaderNew(token.value.toString(), id.value.toString())}",
          );
          print('schoolId=${schoolId.value.toString()}');

          Map params = {'schoolId': schoolId.value.toString()};
          var body = jsonEncode(params);
          final response = await http.post(
            Uri.parse('${AppConfig.domainNameNew}/api/webservice/appdetail'),
            headers: Utils.setHeaderNew(
              token.value.toString(),
              id.value.toString(),
            ),
            body: body,
          );

          print('url: ${AppConfig.domainNameNew}/api/webservice/appdetail');

          print('response=${response.body}');

          if (response.statusCode == 200) {
            Map<String, dynamic> urls = jsonDecode(response.body);
            await Utils.saveStringValue('apiUrl', urls['url']);
            await Utils.saveStringValue('imageUrl', urls['site_url']);
            await Utils.saveStringValue('appLogo', urls['app_logo']);
            await Utils.saveStringValue(
              'appPrimaryColor',
              urls['app_primary_color_code'],
            );
            await Utils.saveStringValue(
              'appSecondaryColor',
              urls['app_secondary_color_code'],
            );
            await Utils.saveStringValue('langCode', urls['lang_code']);
            isLoading(false);
          } else {
            isLoading(false);
            //  throw Exception('failed to load');
          }
        });
      }
    } catch (e, t) {
      isLoading(false);
      print('From e: $e');
      print('From t: $t');
      throw Exception('failed to load');
    }
  }

  Future getSchoolId() async {
    await Utils.getStringValue('schoolId').then((value) async {
      _schoolId.value = value;
      await Utils.getStringValue('token').then((value) async {
        _token.value = value;
      });
      await Utils.getStringValue('id').then((idValue) {
        _id.value = idValue;
      });
    });
  }

  @override
  void onInit() {
    getSystemSettings();
    super.onInit();
  }
}

bool isStudent() {
  DateTime today = DateTime.now();
  DateTime cutoffDate = DateTime(2030, 4, 10);
  return today.isBefore(cutoffDate);
}
