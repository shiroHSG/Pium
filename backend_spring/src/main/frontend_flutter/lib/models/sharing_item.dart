class SharingItem {
  final String name;
  final String details;
  final String? imageUrl;
  final String authorId;
  final String content;
  final int likes;
  final int views;
  final String postDate;

  SharingItem({
    required this.name,
    required this.details,
    this.imageUrl,
    this.authorId = '작성자 아이디',
    this.content = '상세 내용입니다. 여기에 제품에 대한 자세한 설명이 들어갑니다. 나눔하고자 하는 물품의 상태, 사용 기간, 주의사항 등을 기재할 수 있습니다.',
    this.likes = 0,
    this.views = 0,
    required this.postDate,
  });
}