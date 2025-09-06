import 'package:flutter/material.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewPage extends StatefulWidget {
  final String imageUrl;
  final String title;
  const ImagePreviewPage(
      {super.key, required this.imageUrl, required this.title});

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomScreenAppBarWidget(
        title: "",
      ),
      body: PhotoView(
        imageProvider: NetworkImage(widget.imageUrl),
        backgroundDecoration: const BoxDecoration(
          color: Colors.white,
        ),
      ),
    );
  }
}
