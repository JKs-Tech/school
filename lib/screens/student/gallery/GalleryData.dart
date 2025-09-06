class GalleryData {
  String? url;
  int? type;
  String? title;

  GalleryData({this.url, this.type, this.title});

  @override
  String toString() {
    return 'GalleyData{url: $url, type: $type, title: $title}';
  }
}
