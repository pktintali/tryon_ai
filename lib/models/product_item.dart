import 'dart:io';

/// A saved shared item from the user: it may be a URL/text and/or an image file.
class ProductItem {
  final String? url;
  final String? title;
  final File? imageFile;
  final DateTime savedAt;

  ProductItem({this.url, this.title, this.imageFile, DateTime? savedAt})
      : savedAt = savedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'imagePath': imageFile?.path,
        'savedAt': savedAt.toIso8601String(),
      };

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    final imagePath = json['imagePath'] as String?;
    return ProductItem(
      url: json['url'] as String?,
      title: json['title'] as String?,
      imageFile: imagePath != null ? File(imagePath) : null,
      savedAt:
          DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
