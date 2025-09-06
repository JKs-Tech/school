import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/chat/views/FilePreview/ImagePreview.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:photo_view/photo_view.dart';

import 'Gallery.dart';

class GalleryType {
  static const GALLEY_IMAGE = GalleryType(0);
  static const GALLEY_HEADER = GalleryType(1);

  final int value;

  const GalleryType(this.value);
}

class GalleryActivity extends StatefulWidget {
  const GalleryActivity({super.key});

  @override
  _GalleryActivityState createState() => _GalleryActivityState();
}

class _GalleryActivityState extends State<GalleryActivity> {
  String _token = '', _id = '', imageBaseUrl = '';
  int _studentId = 0;
  bool isLoading = false;
  List<Gallery> galleryList = [];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
    imageBaseUrl = await InfixApi.getImageUrl();
    print('gallery imageBaseUrl = $imageBaseUrl');
    await loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final dateFrom = Utils.getDateOfMonth(DateTime.now(), "first");
      final dateTo = Utils.getDateOfMonth(DateTime.now(), "last");

      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getDashBoardUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode({
          "student_id": _studentId.toString(),
          "date_from": dateFrom,
          "date_to": dateTo,
          'schoolId': await Utils.getStringValue('schoolId'),
        }),
      );

      if (response.statusCode == 200) {
        final result = response.body;
        Map<String, dynamic> object = json.decode(result);
        List<dynamic> gallery = object["gallery"];
        galleryList.clear();
        galleryList = List<Gallery>.from(
          gallery.map((galleryJson) => Gallery.fromJson(galleryJson)),
        );
      }
    } catch (e) {
      print('Gallery activity error  = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Gallery'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : galleryList.isEmpty
                ? Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/no_data.png',
                        width: 200,
                        height: 200,
                      ),
                      Text('No Image Available'),
                    ],
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ListView.builder(
                    itemCount: galleryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              galleryList[index].title ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5.0,
                                  mainAxisSpacing: 5.0,
                                ),
                            itemCount: galleryList[index].galleryImages?.length,
                            itemBuilder: (context, itemIndex) {
                              return GestureDetector(
                                onTap: () {
                                  openZoomView(
                                    context,
                                    galleryList[index].title ?? "",
                                    imageBaseUrl +
                                        (galleryList[index]
                                                .galleryImages?[itemIndex]
                                                .url ??
                                            ''),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Image.network(
                                    imageBaseUrl +
                                        (galleryList[index]
                                            .galleryImages?[itemIndex]
                                            .url ?? ''),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
      ),
    );
  }

  void openZoomView(BuildContext context, String title, String url) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(url),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              heroAttributes: PhotoViewHeroAttributes(tag: url),
              onTapUp: (context, details, controllerValue) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ImagePreviewPage(imageUrl: url, title: title),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}
