// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

import 'package:fluttertoast/fluttertoast.dart';
import 'package:infixedu/screens/student/studyMaterials/StudyMaterialViewer.dart';
//import 'package:pdf_flutter/pdf_flutter.dart';

// Project imports:
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/widget/Line.dart';

// import 'package:infixedu/utils/pdf_flutter.dart';

class UploadedFilesView extends StatefulWidget {
  const UploadedFilesView({
    super.key,
    required this.files,
    required this.fileName,
  });

  final List<String> files;
  final String fileName;

  @override
  _UploadedFilesViewState createState() => _UploadedFilesViewState();
}

class _UploadedFilesViewState extends State<UploadedFilesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: widget.fileName),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: widget.files.length,
          separatorBuilder: (context, index) {
            return const BottomLine();
          },
          itemBuilder: (context, index) {
            return widget.files[index].contains('.pdf')
                ? InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => DownloadViewer(
                              title: 'PDF',
                              filePath: InfixApi.root + widget.files[index],
                            ),
                      ),
                    );
                    Fluttertoast.showToast(msg: 'PDF Viewer not available');
                  },
                  child: Stack(
                    fit: StackFit.loose,
                    children: [
                      // PDF.network(
                      //   InfixApi.root + widget.files[index],
                      //   height: 300,
                      //   width: double.maxFinite,
                      // ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.deepPurple,
                            ),
                            Text(
                              'View',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                : SizedBox(
                  height: 300,
                  width: double.maxFinite,
                  child: InkWell(
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => StudyMaterialViewer(
                      //       title: 'Image',
                      //       filePath: InfixApi.root + widget.files[index],
                      //     ),
                      //   ),
                      // );
                    },
                    child: Image.network(
                      InfixApi.root + widget.files[index],
                      fit: BoxFit.fill,
                    ),
                  ),
                );
            // : ExtendedImage.network(
            //   InfixApi.root + widget.files[index],
            //   fit: BoxFit.fill,
            //   cache: true,
            //   mode: ExtendedImageMode.gesture,
            //   initGestureConfigHandler: (state) {
            //     return GestureConfig(
            //       minScale: 0.9,
            //       animationMinScale: 0.7,
            //       maxScale: 3.0,
            //       animationMaxScale: 3.5,
            //       speed: 1.0,
            //       inertialSpeed: 100.0,
            //       initialScale: 1.0,
            //       inPageView: true,
            //       initialAlignment: InitialAlignment.center,
            //     );
            //   },
            //   //cancelToken: cancellationToken,
            // );
          },
        ),
      ),
    );
  }
}
