import 'dart:developer';

import 'package:get/get.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/model/StudentRecord.dart';

class UserController extends GetxController {
  final Rx<int> _studentId = 0.obs;

  Rx<int> get studentId => _studentId;

  final Rx<String> _token = "".obs;

  Rx<String> get token => _token;

  final Rx<String> _schoolId = "".obs;

  Rx<String> get schoolId => _schoolId;

  final Rx<String> _id = "".obs;

  Rx<String> get id => _id;

  final Rx<String> _className = "".obs;

  Rx<String> get className => _className;

  final Rx<String> _sectionName = "".obs;

  Rx<String> get sectionName => _sectionName;

  final Rx<String> _fullName = "".obs;

  Rx<String> get fullName => _fullName;

  final Rx<String> _role = "".obs;

  Rx<String> get role => _role;

  Rx<bool> isLoading = false.obs;

  final Rx<StudentRecords> _studentRecord = StudentRecords().obs;

  Rx<StudentRecords> get studentRecord => _studentRecord;

  Rx<Record> selectedRecord = Record().obs;

  Future getStudentRecord() async {
    log('get record ${studentId.value}');
    try {
      isLoading(true);
      await getIdToken().then((value) async {
        Map<String, dynamic> values = {
          'id': int.parse(id.value),
          'student_id': studentId.value,
          'full_name': fullName.value,
          'class': className.value,
          'section': sectionName.value,
        };

        print('values = ${values.toString()}');

        Map<String, dynamic> records = {
          'records': [values],
        };

        print('records = ${records.toString()}');

        final studentRecords = studentRecordsFromJson(records);
        print('studentRecords = ${studentRecords.records?.length}');
        print('studentRecords = ${studentRecords.records.toString()}');
        _studentRecord.value = studentRecords;
        if (_studentRecord.value.records?.isNotEmpty ?? false) {
          selectedRecord.value =
              _studentRecord.value.records?.first ?? Record();
        }
        isLoading(false);
      });
    } catch (e, t) {
      print('From T: $t');
      print('From E: $e');
      isLoading(false);
      throw Exception('failed to load $e');
    }
  }

  Future getIdToken() async {
    await Utils.getStringValue('token').then((value) async {
      _token.value = value;
      await Utils.getStringValue('rule')
          .then((ruleValue) {
            _role.value = ruleValue;
          })
          .then((value) async {
            if (_role.value == "2") {
              await Utils.getIntValue('studentId').then((value) {
                _studentId.value = value;
              });
            }
            await Utils.getStringValue('schoolId').then((schoolIdVal) {
              _schoolId.value = schoolIdVal;
            });
            await Utils.getStringValue('id').then((value) {
              _id.value = value;
            });
            await Utils.getStringValue('className').then((value) {
              _className.value = value;
            });
            await Utils.getStringValue('sectionName').then((value) {
              _sectionName.value = value;
            });
            await Utils.getStringValue('full_name').then((value) {
              _fullName.value = value;
            });
          });
    });
  }
}
