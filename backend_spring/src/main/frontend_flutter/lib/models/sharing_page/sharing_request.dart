class SharingRequest {
  final String title;
  final String content;
  final String category;
  final String? imgUrl;

  SharingRequest({
    required this.title,
    required this.content,
    required this.category,
    this.imgUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'imgUrl': imgUrl,
    };
  }
}
