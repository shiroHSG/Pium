class ChatMessage {
  final int messageId;
  final int senderId;
  final String senderNickname;
  final String senderProfileImageUrl;
  final String content;
  final DateTime sentAt;
  final int unreadCount;

  // ✅ 현재 로그인 유저가 보낸 메시지인지 확인하는데 사용
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
      senderProfileImageUrl: json['senderProfileImageUrl'] ?? '',
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
      unreadCount: json['unreadCount'],
      isMe: json['senderId'] == currentUserId,
    );
  }
}
