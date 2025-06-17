class BabyRecordEntry {
  final int? id;
  final int? childId;
  final String title;
  final String? publicContent;
  final String? privateContent;
  final bool published;
  final DateTime createdAt;
  final String? imageUrl; // ✅ imageUrl 필드 추가

  BabyRecordEntry({
    this.id,
    this.childId,
    required this.title,
    this.publicContent,
    this.privateContent,
    required this.published,
    required this.createdAt,
    this.imageUrl, // ✅ 추가
  });

  // JSON 형태로 변환
  Map<String, dynamic> toJson() => {
    'id': id,
    'childId': childId,
    'title': title,
    'publicContent': publicContent,
    'content': privateContent,
    'published': published,
    'createdAt': createdAt.toIso8601String(),
    'imageUrl': imageUrl, // ✅ 추가
  };

  // JSON 데이터로부터 객체 생성
  factory BabyRecordEntry.fromJson(Map<String, dynamic> json) {
    // createdAt 처리
    DateTime createdAt = DateTime.now();
    if (json['createdAt'] is List) {
      final list = json['createdAt'] as List;
      if (list.length >= 6) {
        createdAt = DateTime(
          list[0], list[1], list[2], list[3], list[4], list[5],
          list.length > 6 ? (list[6] / 1000000).round() : 0, // 나노 → 밀리초
        );
      }
    }

    return BabyRecordEntry(
      id: json['id'],
      childId: json['childId'] as int?,
      title: json['title'] as String? ?? '',
      publicContent: json['publicContent'] as String? ?? '',
      privateContent: json['content'] as String? ?? '',
      published: json['published'] == true || json['published'] == 1,
      createdAt: createdAt, // ✅ 여기로 교체 (중복된 잘못된 줄 제거)
      imageUrl: json['imageUrl'] as String?, // ✅ 안전 처리
    );
  }
}
