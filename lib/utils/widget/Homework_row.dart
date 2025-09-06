// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:infixedu/screens/chat/views/FilePreview/ImagePreview.dart';
// Project imports:
import 'package:infixedu/screens/student/homework/UploadHomework.dart';
import 'package:infixedu/screens/student/studyMaterials/StudyMaterialViewer.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/model/StudentHomework.dart';

// ignore: must_be_immutable
class StudentHomeworkRow extends StatefulWidget {
  Homeworklist homework;
  String type;
  final String documentUrl;
  final String homeworkFile;

  StudentHomeworkRow({
    super.key,
    required this.homework,
    required this.type,
    required this.documentUrl,
    required this.homeworkFile,
  });

  @override
  _StudentHomeworkRowState createState() => _StudentHomeworkRowState();
}

class _StudentHomeworkRowState extends State<StudentHomeworkRow> {
  int? rule;
  double progress = 0;

  // ignore: prefer_typing_uninitialized_variables
  var received;

  Random random = Random();

  final GlobalKey _globalKey = GlobalKey();
  String? _id;
  // fileName = "", downloadPath, uploadFilePath;
  String status = "";

  String studentUpload = "";
  String teacherUpload = "";

  @override
  void initState() {
    status =
        (widget.homework.evaluationDate == '0000-00-00' ||
                widget.homework.evaluationDate == '' ||
                widget.homework.evaluationDate == null)
            ? 'incompleted'
            : 'Completed';

    if (widget.homework.document != null &&
        (widget.homework.document?.isNotEmpty ?? false)) {
      teacherUpload = widget.homeworkFile + (widget.homework.document ?? '');
    }

    if (widget.homework.homeworkUploadedFile != null &&
        (widget.homework.homeworkUploadedFile?.isNotEmpty ?? false)) {
      studentUpload =
          widget.documentUrl + (widget.homework.homeworkUploadedFile ?? '');
    }

    Utils.getStringValue('id').then((value) {
      _id = value;
    });

    Utils.getStringValue('rule').then((value) {
      rule = int.parse(value);
    });
    initData();
    super.initState();
  }

  Future<void> initData() async {}

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _globalKey,
      child: InkWell(
        onTap: () {
          showAlertDialog(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.homework.name ?? "",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showAlertDialog(context);
                  },
                  child: Text(
                    'View'.tr,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.deepPurpleAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Created'.tr,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          widget.homework.homeworkDate ?? 'N/A',
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Submission'.tr,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          widget.homework.submitDate ?? 'N/A',
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Evaluation'.tr,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          widget.homework.evaluationDate ?? 'N/A',
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Status'.tr,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10.0),
                        getStatus(context, status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            // widget.homework.obtainedMarks == ""
            //     ? Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         Text(
            //           'Marks'.tr,
            //           maxLines: 1,
            //           style: Theme.of(context).textTheme.headlineMedium
            //               ?.copyWith(fontWeight: FontWeight.w500),
            //         ),
            //         const SizedBox(height: 10.0),
            //         Text(
            //           widget.homework.marks == null
            //               ? 'N/A'
            //               : widget.homework.marks.toString(),
            //           maxLines: 1,
            //           style: Theme.of(context).textTheme.headlineMedium,
            //         ),
            //       ],
            //     )
            //     : Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         Text(
            //           'Obtained Marks',
            //           maxLines: 1,
            //           style: Theme.of(context).textTheme.headlineMedium
            //               ?.copyWith(fontWeight: FontWeight.w500),
            //         ),
            //         const SizedBox(height: 10.0),
            //         Text(
            //           widget.homework.obtainedMarks == null
            //               ? 'N/A'
            //               : widget.homework.obtainedMarks.toString(),
            //           maxLines: 1,
            //           style: Theme.of(context).textTheme.headlineMedium,
            //         ),
            //       ],
            //     ),
            Container(
              height: 0.5,
              margin: const EdgeInsets.only(top: 10.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Colors.purple, Colors.deepPurple],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    top: 20.0,
                    right: 10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.homework.name ?? "",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          // widget.homework.obtainedMarks == ""
                          //     ? Text(
                          //       "Marks: ".tr + (widget.homework.marks ?? 'N/A'),
                          //       style:
                          //           Theme.of(context).textTheme.headlineSmall,
                          //       maxLines: 1,
                          //     )
                          //     : Text(
                          //       "Obtained Marks: ${widget.homework.obtainedMarks ?? ''}",
                          //       style:
                          //           Theme.of(context).textTheme.headlineSmall,
                          //       maxLines: 1,
                          //     ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Created'.tr,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    widget.homework.homeworkDate ?? "",
                                    maxLines: 1,
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineMedium,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Submission'.tr,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    widget.homework.submitDate ?? "",
                                    maxLines: 1,
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineMedium,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Evaluation'.tr,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    widget.homework.evaluationDate ?? 'N/A',
                                    maxLines: 1,
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineMedium,
                                  ),
                                ],
                              ),
                            ),
                            widget.type == 'student'
                                ? Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Status'.tr,
                                        maxLines: 1,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      getStatus(context, status),
                                    ],
                                  ),
                                )
                                : Container(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 10.0),
                              Html(data: widget.homework.description ?? ''),
                              if (widget.homework.document != null &&
                                  widget.homework.document != '')
                                const SizedBox(height: 20.0),
                              if (studentUpload.isNotEmpty)
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (studentUpload.toLowerCase().endsWith(
                                        '.pdf',
                                      )) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => DownloadViewer(
                                                  title:
                                                      widget.homework.name ??
                                                      "",
                                                  filePath: studentUpload,
                                                ),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ImagePreviewPage(
                                                  imageUrl: studentUpload,
                                                  title:
                                                      widget.homework.name ??
                                                      "",
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      // Set button background color here
                                      foregroundColor:
                                          Colors.white, // Set text color here
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      // This makes the button wrap its content
                                      children: [
                                        Icon(Icons.file_copy_rounded, size: 24),
                                        const SizedBox(width: 4),
                                        Text(
                                          'View Uploaded File',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            teacherUpload.isEmpty
                                ? Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: ScreenUtil().setWidth(145),
                                    height: ScreenUtil().setHeight(40),
                                  ),
                                )
                                : InkWell(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 150,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    decoration: Utils.gradientBtnDecoration,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Expanded(
                                          child: Icon(
                                            Icons.file_copy_rounded,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          "View".tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    if (teacherUpload.toLowerCase().endsWith(
                                      '.pdf',
                                    )) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DownloadViewer(
                                                title: widget.homework.name,
                                                filePath: teacherUpload,
                                              ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ImagePreviewPage(
                                                imageUrl: teacherUpload,
                                                title:
                                                    widget.homework.name ?? "",
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                            widget.type == 'student' && rule != 3
                                ? status == "incompleted"
                                    ? InkWell(
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 150,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        decoration: Utils.gradientBtnDecoration,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Expanded(
                                              child: Icon(
                                                Icons.cloud_download,
                                                size: 24,
                                              ),
                                            ),
                                            Text(
                                              "Upload".tr,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        showDialog<void>(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Upload Homework'),
                                              content: SingleChildScrollView(
                                                // Set the desired height here
                                                child: UploadHomework(
                                                  homework: widget.homework,
                                                  userID: _id ?? "",
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    )
                                    : Container()
                                : Container(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget getStatus(BuildContext context, String status) {
    if (status == 'incompleted') {
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.redAccent),
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: Text(
            'Incomplete',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else if (status == 'Completed') {
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.greenAccent),
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: Text(
            'Completed',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
