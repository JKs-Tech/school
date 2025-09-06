import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentProfileDetailsScreen extends StatefulWidget {
  const StudentProfileDetailsScreen({super.key});

  @override
  _StudentProfileDetailsScreenState createState() =>
      _StudentProfileDetailsScreenState();
}

class _StudentProfileDetailsScreenState
    extends State<StudentProfileDetailsScreen> {
  String name = "",
      admissionNo = "",
      rollNo = "",
      className = "",
      _token = '',
      _id = '';
  String profileImageUrl = "";
  int _studentId = 0;
  bool isLoading = false;
  Map<String, dynamic>? fatherDetails;
  Map<String, dynamic>? motherDetails;
  Map<String, dynamic>? guardianDetails;
  Map<String, String> studentData = {};
  List<dynamic> customFields = [];
  Map<String, dynamic> studentFields = {};
  Map<String, dynamic>? studentResult;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
    _getDataFromApi();
  }

  Future<void> _getDataFromApi() async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'student_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getProfileUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('profile result = $result');
        processResponseData(result);
      }
    } catch (e) {
      print('student profile screen error = ${e.toString()}');
      print('student profile screen error = $e}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void processResponseData(Map<String, dynamic> data) {
    studentResult = data['student_result'];
    print('profile studentResult = $studentResult');
    if (studentResult?.isEmpty ?? true) {
      return;
    }

    studentData = {
      'Admission Date': Utils.parseDate(
        "yyyy-MM-dd",
        "dd/MM/yyyy",
        studentResult?['admission_date'],
      ),
      'Date of Birth': Utils.parseDate(
        "yyyy-MM-dd",
        "dd/MM/yyyy",
        studentResult?['dob'],
      ),
      'Category': studentResult?['category'],
      'Mobile No': studentResult?['mobileno'],
      'Caste': studentResult?['cast'],
      'Religion': studentResult?['religion'],
      'Email': studentResult?['email'],
      'Current Address': studentResult?['current_address'],
      'Permanent Address': studentResult?['permanent_address'],
      'Blood Group': studentResult?['blood_group'],
      'Height': studentResult?['height'],
      'Weight': studentResult?['weight'],
      'As On Date': Utils.parseDate(
        "yyyy-MM-dd",
        "dd/MM/yyyy",
        studentResult?['measurement_date'],
      ),
    };
    print('profile studentData = $studentData');
    fatherDetails = {
      "title": "Father",
      "name": studentResult?["father_name"],
      "contact": studentResult?["father_phone"],
      "occupation": studentResult?["father_occupation"],
      "image":
          studentResult?["father_pic"] == null
              ? ""
              : "${AppConfig.domainNameNew}/" + studentResult?["father_pic"],
    };

    print('profile fatherDetails = $fatherDetails');

    motherDetails = {
      "title": "Mother",
      "name": studentResult?["mother_name"],
      "contact": studentResult?["mother_phone"],
      "occupation": studentResult?["mother_occupation"],
      "image":
          studentResult?["mother_pic"] == null
              ? ""
              : "${AppConfig.domainNameNew}/" + studentResult?["mother_pic"],
    };

    print('profile motherDetails = $motherDetails');

    guardianDetails = {
      "title": "Guardian",
      "name": studentResult?["guardian_name"],
      "contact": studentResult?["guardian_phone"],
      "occupation": studentResult?["guardian_occupation"],
      "image":
          studentResult?["guardian_pic"] == null
              ? ""
              : "${AppConfig.domainNameNew}/" + studentResult?["guardian_pic"],
      "relation": studentResult?["guardian_relation"],
      "email": studentResult?["guardian_email"],
      "address": studentResult?["guardian_address"],
    };
    print('profile guardianDetails = $guardianDetails');
    studentFields = data['student_fields'];
    try {
      customFields = data['custom_fields'];
    } catch (e) {}
    print('profile studentFields = $studentFields');
    print('profile customFields = $customFields');
    setState(() {
      admissionNo = studentResult?["admission_no"];
      print('profile admissionNo = $admissionNo');
      rollNo = studentResult?["roll_no"];
      print('profile rollNo = $rollNo');
      className = studentResult?["class"] + " - " + studentResult?["section"];
      print('profile className = $className');

      profileImageUrl =
          studentResult?["image"] == null
              ? ""
              : "${AppConfig.domainNameNew}/" + studentResult?["image"];
      print('profile profileImageUrl = $profileImageUrl');
      name = studentResult?["firstname"];
      if (studentResult?["lastname"] != null &&
          studentResult?["lastname"] != "") {
        name = name + studentResult?["lastname"];
      }
      print('profile name = $name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Profile'),
      body:
          isLoading
              ? Center(child: CupertinoActivityIndicator())
              : studentResult == null
              ? Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/no_data.png',
                      width: 200,
                      height: 200,
                    ),
                    Text('No Profile Available'),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          profileImageUrl.isNotEmpty
                              ? CircleAvatar(
                                radius: 60,
                                backgroundImage: CachedNetworkImageProvider(
                                  profileImageUrl,
                                ),
                                backgroundColor: Colors.transparent,
                              )
                              : Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.black,
                              ),
                          SizedBox(height: 10),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Admission No: $admissionNo"),
                          Text("Roll No: $rollNo"),
                          Text("Class: $className"),
                        ],
                      ),
                    ),
                    DefaultTabController(
                      length: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TabBar(
                            tabs: [
                              Tab(text: 'Personal'),
                              Tab(text: 'Parent'),
                              Tab(text: 'Others'),
                            ],
                          ),
                          SizedBox(
                            height: 600,
                            child: TabBarView(
                              children: [
                                StudentPersonalDetail(
                                  studentData: studentData,
                                  studentFields: studentFields,
                                  customFields: customFields,
                                ),
                                StudentParentsDetail(
                                  fatherDetails: fatherDetails ?? {},
                                  motherDetails: motherDetails ?? {},
                                  guardianDetails: guardianDetails ?? {},
                                ),
                                StudentOtherDetail(
                                  studentResult: studentResult ?? {},
                                  studentFields: studentFields,
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
    );
  }
}

class StudentParentsDetail extends StatelessWidget {
  final Map<String, dynamic> fatherDetails;
  final Map<String, dynamic> motherDetails;
  final Map<String, dynamic> guardianDetails;

  const StudentParentsDetail({
    super.key,
    required this.fatherDetails,
    required this.motherDetails,
    required this.guardianDetails,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Wrap with SingleChildScrollView
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            ParentDetailsWidget(details: fatherDetails),
            const SizedBox(height: 16),
            ParentDetailsWidget(details: motherDetails),
            const SizedBox(height: 16),
            GuardianDetailsWidget(details: guardianDetails),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class GuardianDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> details;

  const GuardianDetailsWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                details["image"] != null && details["image"] != ""
                    ? CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(details["image"]),
                      backgroundColor: Colors.transparent,
                    )
                    : Icon(Icons.person, size: 35, color: Colors.black),
                Text(
                  details['title'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDetailRow(
                    'assets/images/ic_user.png',
                    'Name: ${details["name"]}',
                  ),
                  buildDetailRow(
                    'assets/images/ic_phone_filled.png',
                    'Contact: ${details["contact"]}',
                  ),
                  buildDetailRow(
                    'assets/images/ic_briefcase.png',
                    'Occupation: ${details["occupation"]}',
                  ),
                  buildDetailRow(
                    'assets/images/ic_relation.png',
                    'Relation: ${details["relation"]}',
                  ),
                  buildDetailRow(
                    'assets/images/ic_email_filled.png',
                    'Email: ${details["email"]}',
                  ),
                  buildDetailRow(
                    'assets/images/ic_location.png',
                    'Address: ${details["address"]}',
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

class ParentDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> details;

  const ParentDetailsWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                details["image"] != null && details["image"] != ""
                    ? CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(details["image"]),
                      backgroundColor: Colors.transparent,
                    )
                    : Icon(Icons.person, size: 35, color: Colors.black),
                Text(
                  details['title'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDetailRow(
                    'assets/images/ic_user.png',
                    'Name: ${details["name"]}',
                  ),
                  buildDetailRow(
                    'assets/images/ic_phone_filled.png',
                    'Contact: ${details["contact"]}',
                  ),
                  buildDetailRow(
                    'assets/images/ic_briefcase.png',
                    'Occupation: ${details["occupation"]}',
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

Widget buildDetailRow(String imagePath, String text) {
  return Row(
    children: [
      Image.asset(imagePath, width: 20, height: 20),
      const SizedBox(width: 16),
      Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
    ],
  );
}

class StudentOtherDetail extends StatelessWidget {
  final Map<String, dynamic> studentResult;
  final Map<String, dynamic> studentFields;

  const StudentOtherDetail({
    super.key,
    required this.studentResult,
    required this.studentFields,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildInfoRow("Previous School", studentResult['previous_school']),
          buildInfoRow("National ID No", studentResult['adhar_no']),
          buildInfoRow("Local ID No", studentResult['samagra_id']),
          buildInfoRow("Bank Account No", studentResult['bank_account_no']),
          buildInfoRow("Bank Name", studentResult['bank_name']),
          buildInfoRow("IFSC Code", studentResult['ifsc_code']),
          buildInfoRow("RTE", studentResult['rte']),
          buildInfoRow("Student House", studentResult['house_name']),
          buildInfoRow("Vehicle Route", studentResult['route_title']),
          buildInfoRow("Vehicle No", studentResult['vehicle_no']),
          buildInfoRow("Driver Name", studentResult['driver_name']),
          buildInfoRow("Driver Contact", studentResult['driver_contact']),
          buildInfoRow("Hostel", studentResult['hostel_name']),
          buildInfoRow("Hostel Room No", studentResult['room_no']),
          buildInfoRow("Hostel Room Type", studentResult['room_type']),
        ],
      ),
    );
  }

  Widget buildInfoRow(String title, String data) {
    String visibilityField = getFieldVisibility(title);
    bool isVisible =
        studentFields.containsKey(visibilityField) || visibilityField == '';
    return Visibility(
      visible: isVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8), // Add a bit of spacing
            Flexible(
              flex: 1,
              child: Text(
                data ?? 'N/A', // If data is null, display 'N/A'
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentPersonalDetail extends StatelessWidget {
  final Map<String, dynamic> studentData;
  final List<dynamic> customFields;
  final Map<String, dynamic> studentFields;

  const StudentPersonalDetail({
    super.key,
    required this.studentData,
    required this.customFields,
    required this.studentFields,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: studentData.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        String fieldName = studentData.keys.elementAt(index);
        String fieldValue = studentData[fieldName];
        String visibilityField = getFieldVisibility(fieldName);
        bool isVisible =
            studentFields.containsKey(visibilityField) || visibilityField == '';

        return Visibility(
          visible: isVisible,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    fieldName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(flex: 3, child: Text(fieldValue.toString())),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> buildStudentDataWidget(int index) {
    String fieldName = studentData.keys.elementAt(index);
    String fieldValue = studentData[fieldName];
    String visibilityField = getFieldVisibility(fieldName);
    bool isVisible =
        studentFields.containsKey(visibilityField) || visibilityField == '';

    return [
      Visibility(
        visible: isVisible,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  fieldName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(flex: 3, child: Text(fieldValue.toString())),
            ],
          ),
        ),
      ),
    ];
  }

  Widget buildCustomFieldWidget(int index) {
    String fieldName = customFields[index].keys.elementAt(0);
    String fieldValue = customFields[index][fieldName];

    return ListTile(title: Text(fieldName), subtitle: Text(fieldValue));
  }
}

String getFieldVisibility(String fieldName) {
  String visibilityField = '';
  switch (fieldName) {
    case 'Admission Date':
      visibilityField = 'admission_date';
      break;
    case 'Category':
      visibilityField = 'category';
      break;
    case 'Mobile No':
      visibilityField = 'mobile_no';
      break;
    case 'Religion':
      visibilityField = 'religion';
      break;
    case 'Email':
      visibilityField = 'student_email';
      break;
    case 'Current Address':
      visibilityField = 'current_address';
      break;
    case 'Permanent Address':
      visibilityField = 'permanent_address';
      break;
    case 'Blood Group':
      visibilityField = 'blood_group';
      break;
    case 'Height':
      visibilityField = 'student_height';
      break;
    case 'Weight':
      visibilityField = 'student_weight';
      break;
    case 'As On Date':
      visibilityField = 'measurement_date';
      break;
    case 'RTE':
      visibilityField = 'rte';
      break;
    case 'Local ID No':
      visibilityField = 'local_identification_no';
      break;
    case 'National ID No':
      visibilityField = 'national_identification_no';
      break;
    case 'Bank Account No':
      visibilityField = 'bank_account_no';
      break;
    case 'Bank Name':
      visibilityField = 'bank_name';
      break;
    case 'IFSC Code':
      visibilityField = 'ifsc_code';
      break;
    case 'Student House':
      visibilityField = 'house_name';
      break;
    case 'Vehicle Route':
      visibilityField = 'route_list';
      break;
    case 'Vehicle No':
      visibilityField = 'vehicle_no';
      break;
    case 'Driver Name':
      visibilityField = 'driver_name';
      break;
    case 'Driver Contact':
      visibilityField = 'driver_contact';
      break;
    case 'Hostel':
      visibilityField = 'hostel_name';
      break;
    case 'Hostel Room No':
      visibilityField = 'room_no';
      break;
    case 'Hostel Room Type':
      visibilityField = 'room_type';
      break;
  }
  return visibilityField;
}
