// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pdfrx/pdfrx.dart';

// import 'package:infixedu/utils/pdf_flutter.dart';

class DownloadViewer extends StatefulWidget {
  final String? title;
  final String? filePath;
  const DownloadViewer({super.key, this.title, this.filePath});
  @override
  DownloadViewerState createState() => DownloadViewerState();
}

class DownloadViewerState extends State<DownloadViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title ?? ''),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: PdfViewer.uri(
        Uri.parse(widget.filePath ?? ''),
        params: PdfViewerParams(
          backgroundColor: Colors.white,
          loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
            return Center(
              child: CircularProgressIndicator(
                value: totalBytes != null ? bytesDownloaded / totalBytes : null,
                backgroundColor: Colors.white,
              ),
            );
          },
          onViewerReady: (document, controller) {
            // Handle additional setup after the viewer is ready, if needed
          },
        ),
      ),
    );
  }
}
