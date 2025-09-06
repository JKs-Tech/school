import 'package:flutter/material.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'Homework.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

class AdminCreateHomeworkScreen extends StatefulWidget {
  final List<Homework> homeworkList;
  const AdminCreateHomeworkScreen({super.key, required this.homeworkList});

  @override
  _AdminCreateHomeworkScreenState createState() =>
      _AdminCreateHomeworkScreenState();
}

class _AdminCreateHomeworkScreenState extends State<AdminCreateHomeworkScreen> {
  String selectedClass = '';
  String selectedSection = '';
  String selectedSubject = '';
  TextEditingController descriptionController = TextEditingController();
  File? selectedFile;
  bool isFileUploaded = false,
      isSubmitting = false,
      isHomeworkDateSelected = false,
      isSubmissionDateSelected = false;
  String? fileName,
      _token,
      _id,
      createDateApi,
      createDate,
      homeworkDate,
      homeworkDateApi,
      submissionDate,
      submissionDateApi;
  int? _studentId;

  @override
  void initState() {
    super.initState();
    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getIntValue('studentId').then((value) {
      _studentId = value;
    });
    Utils.getStringValue('id').then((idValue) {
      setState(() {
        _id = idValue;
      });
    });
    String oldFormat = "MM/dd/yyyy";
    String newFormat = "yyyy-MM-dd";
    DateTime currentDate = DateTime.now();
    String currentDateAndTime = DateFormat(oldFormat).format(currentDate);
    createDate = currentDateAndTime;
    DateTime myDate = DateFormat(oldFormat).parse(createDate ?? '');
    createDateApi = DateFormat(newFormat).format(myDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Create Homework'),
      body: isSubmitting
          ? Center(child: CupertinoActivityIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Class"),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButtonFormField<String>(
                          value: selectedClass,
                          onChanged: (newValue) {
                            setState(() {
                              selectedClass = newValue ?? '';
                            });
                          },
                          items: [
                            'Class 1',
                            'Class 2',
                            'Class 3',
                            'Class 4',
                            'Class 5'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration:
                              InputDecoration(hintText: 'Select class'))),
                  SizedBox(height: 16),
                  Text("Section"),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButtonFormField<String>(
                          value: selectedSection,
                          onChanged: (newValue) {
                            setState(() {
                              selectedSection = newValue ?? '';
                            });
                          },
                          items: ['A', 'B', 'C', 'D']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration:
                              InputDecoration(hintText: 'Select section'))),
                  SizedBox(height: 16),
                  Text("Subject"),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButtonFormField<String>(
                          value: selectedSubject.isNotEmpty
                              ? selectedSubject
                              : 'Math',
                          onChanged: (newValue) {
                            setState(() {
                              selectedSubject = newValue ?? "";
                            });
                          },
                          items: ['Math', 'History', 'Science', 'English']
                              .map<DropdownMenuItem<String>>(
                            (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            },
                          ).toList(),
                          decoration:
                              InputDecoration(hintText: 'Select subject'))),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Homework Date: '),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () =>
                            _selectHomeworkDate(context, 'homeworkDate'),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(
                              (homeworkDate != null && homeworkDate!.isNotEmpty)
                                  ? homeworkDate!
                                  : "Select date"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Submission Date:'),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () =>
                            _selectHomeworkDate(context, 'submissionDate'),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text((submissionDate != null &&
                                  submissionDate!.isNotEmpty)
                              ? submissionDate ?? ""
                              : "Select date"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () => _selectFile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Set button background color here
                        foregroundColor: Colors.white, // Set text color here
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Attach document'))),
                  SizedBox(height: 16),
                  Text("Description"),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                          controller: descriptionController,
                          maxLines: 5,
                          minLines: 5,
                          decoration:
                              InputDecoration(hintText: 'Enter description'))),
                  SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () {
                        print(
                            'isSubmissionDateSelected = $isSubmissionDateSelected');
                        print(
                            'isHomeworkDateSelected = $isHomeworkDateSelected');
                        print('selectedClass = $selectedClass');
                        print('selectedSection = $selectedSection');
                        print('selectedSubject = $selectedSubject');
                        print(
                            'descriptionController = ${descriptionController.text.trim()}');
                        if (isSubmissionDateSelected &&
                            isHomeworkDateSelected &&
                            selectedClass.isNotEmpty &&
                            selectedSection.isNotEmpty &&
                            selectedSubject.isNotEmpty &&
                            descriptionController.text.isNotEmpty &&
                            descriptionController.text.isNotEmpty) {
                          _addHomework(context);
                        } else {
                          Fluttertoast.showToast(
                              msg: "All fields are required!");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Set button background color here
                        foregroundColor: Colors.white, // Set text color here
                      ),
                      child: Text('Add Homework')),
                ],
              ),
            ),
    );
  }

  Future<void> _selectHomeworkDate(BuildContext context, String type) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.blue, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // button text color
              ),
            ),
          ),
          child: child ?? Container(),
        );
      },
    );

    if (picked != null) {
      String uiFormat = "dd-MM-yyyy";
      String apiFormat = "yyyy-MM-dd";
      String uiDateTime = DateFormat(uiFormat).format(picked);
      String apiDateTime = DateFormat(apiFormat).format(picked);

      setState(() {
        if (type == 'homeworkDate') {
          homeworkDate = uiDateTime;
          homeworkDateApi = apiDateTime;
          isHomeworkDateSelected = true;
        } else if (type == 'submissionDate') {
          submissionDate = uiDateTime;
          submissionDateApi = apiDateTime;
          isSubmissionDateSelected = true;
        }
      });
    }
  }

  void _addHomework(BuildContext context) {
    final newHomework = Homework(
        classs: selectedClass,
        section: selectedSection,
        subject: selectedSubject,
        homeworkDate: homeworkDateApi ?? '',
        submissionDate: submissionDateApi ?? '',
        attachment: selectedFile!.path,
        description: descriptionController.text);

    setState(() {
      widget.homeworkList.add(newHomework);
    });
    _uploadFile(context); // Navigate back to the list screen
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path ?? '');
        fileName = basename(result.files.single.path ?? '');
        isFileUploaded = true;
      });
    }
  }

  Future<void> _uploadFile(BuildContext context) async {
    setState(() {
      isSubmitting = true;
    });
    try {
      String url = await InfixApi.getApiUrl() + InfixApi.getAddLeaveUrl();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers
          .addAll(Utils.setHeaderNew(_token.toString(), _id.toString()));

      if (selectedFile != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          selectedFile!.readAsBytesSync(),
          filename: fileName,
          contentType: MediaType.parse(Utils.getMimeType(selectedFile!.path)),
        ));
      } else {
        request.fields['file'] = '';
      }
      request.fields['create_date'] = createDateApi ?? '';
      request.fields['homework_date'] = homeworkDateApi ?? '';
      request.fields['submission_date'] = submissionDateApi ?? '';
      request.fields['class'] = selectedClass;
      request.fields['section'] = selectedSection;
      request.fields['subject'] = selectedSubject;
      request.fields['student_id'] = _studentId.toString();
      request.fields['schoolId'] = await Utils.getStringValue('schoolId');

      var response = await request.send();
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Leave saved successfully');
      } else {
        Fluttertoast.showToast(msg: 'Error, Please try again!');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error occurred: $e');
    } finally {
      setState(() {
        isSubmitting = false;
      });
      Navigator.pop(context);
    }
  }
}
