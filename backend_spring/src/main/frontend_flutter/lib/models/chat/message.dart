class ChatMessage {
  final int messageId;
  final int senderId;
  final String senderNickname;
  final String senderProfileImageUrl;
  final String content;
  final DateTime sentAt;
  final int unreadCount;

  final bool isMe;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderNickname,
    required this.senderProfileImageUrl,
    required this.content,
    required this.sentAt,
    required this.unreadCount,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, int currentUserId) {
    return ChatMessage(
      messageId: json['messageId'],
      senderId: json['senderId'],
      senderNickname: json['senderNickname'],
      senderProfileImageUrl: _resolveImageUrl(json['senderProfileImageUrl']),
      content: json['content'],
      sentAt: _parseDateTime(json['sentAt']),
      unreadCount: json['unreadCount'],
      isMe: json['senderId'] == currentUserId,
    );
  }

  /// ✅ 이미지 경로를 절대 URL로 보정
  static String _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return 'http://10.0.2.2:8080${path.startsWith('/') ? path : '/$path'}'
        '?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// ✅ 날짜 파싱
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);

    if (value is String) {
      return DateTime.parse(value);
    }

    if (value is List && value.length >= 6) {
      return DateTime(
        value[0], value[1], value[2], value[3], value[4], value[5],
      );
    }

    throw Exception('Invalid sentAt format: $value');
  }
}
