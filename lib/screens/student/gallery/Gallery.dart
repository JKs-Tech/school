class Gallery {
  final String? id;
  final String? type;
  final String? slug;
  final String? url;
  final String? title;
  final String? description;
  final String? isActive;
  final String? createdAt;
  final String? metaTitle;
  final String? metaDescription;
  final String? metaKeyword;
  final String? featureImage;
  final String? publishDate;
  final String? publish;
  final String? sidebar;
  final List<GalleryImage>? galleryImages;

  Gallery({
    this.id,
    this.type,
    this.slug,
    this.url,
    this.title,
    this.description,
    this.isActive,
    this.createdAt,
    this.metaTitle,
    this.metaDescription,
    this.metaKeyword,
    this.featureImage,
    this.publishDate,
    this.publish,
    this.sidebar,
    this.galleryImages,
  });

  factory Gallery.fromJson(Map<String, dynamic> json) {
    List<GalleryImage> images =
        (json['gallery_images'] as List<dynamic>)
            .map((imageJson) => GalleryImage.fromJson(imageJson))
            .toList();

    return Gallery(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      slug: json['slug'] ?? '',
      url: json['url'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? '',
      createdAt: json['created_at'] ?? '',
      metaTitle: json['meta_title'] ?? '',
      metaDescription: json['meta_description'] ?? '',
      metaKeyword: json['meta_keyword'] ?? '',
      featureImage: json['feature_image'] ?? '',
      publishDate: json['publish_date'] ?? '',
      publish: json['publish'] ?? '',
      sidebar: json['sidebar'] ?? '',
      galleryImages: images,
    );
  }
}

class GalleryImage {
  final String? dirPath;
  final String? imgName;
  final String? url;

  GalleryImage({this.dirPath, this.imgName, this.url});

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      dirPath: json['dir_path'] ?? '',
      imgName: json['img_name'] ?? '',
      url: (json['dir_path'] ?? '') + (json['img_name'] ?? ''),
    );
  }
}
