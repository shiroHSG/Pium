class ChatRoom {
  final int chatRoomId;
  final String type;

  // DM / SHARE
  final String? otherNickname;
  final String? otherProfileImageUrl;

  // SHARE
  final int? sharePostId;
  final String? sharePostTitle;

  // GROUP
  final String? chatRoomName;
  final String? imageUrl;

  final String lastMessage;
  final DateTime? lastSentAt;
  final int unreadCount;

  ChatRoom({
    required this.chatRoomId,
    required this.type,
    this.otherNickname,
    this.otherProfileImageUrl,
    this.sharePostId,
    this.sharePostTitle,
    this.chatRoomName,
    this.imageUrl,
    required this.lastMessage,
    required this.lastSentAt,
    required this.unreadCount,
  });

  /// ✅ 공용 이미지 URL 생성기
  static String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return 'http://10.0.2.2:8080${path.startsWith('/') ? path : '/$path'}'
        '?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// ✅ 날짜 파싱 (String 또는 List[int])
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is List && value.length >= 6) {
      return DateTime(
        value[0], value[1], value[2], value[3], value[4], value[5],
      );
    }
    return null;
  }

  /// ✅ JSON → ChatRoom 객체 변환
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      chatRoomId: json['chatRoomId'],
      type: json['type'],
      otherNickname: json['otherNickname'],
      otherProfileImageUrl: _resolveImageUrl(json['otherProfileImageUrl']),
      sharePostId: json['sharePostId'],
      sharePostTitle: json['sharePostTitle'],
      chatRoomName: json['chatRoomName'],
      imageUrl: _resolveImageUrl(json['imageUrl']),
      lastMessage: json['lastMessage'] ?? '',
      lastSentAt: _parseDateTime(json['lastSentAt']),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
