class ChatRoom {
  final int chatRoomId;
  final String type;

  // DM/SHARE
  final String? otherNickname;
  final String? otherProfileImageUrl;

  // SHARE
  final int? sharePostId;

  // GROUP
  final String? chatRoomName;
  final String? imageUrl;

  final String lastMessage;
  final String lastSentAt;
  final int unreadCount;

  ChatRoom({
    required this.chatRoomId,
    required this.type,
    this.otherNickname,
    this.otherProfileImageUrl,
    this.sharePostId,
    this.chatRoomName,
    this.imageUrl,
    required this.lastMessage,
    required this.lastSentAt,
    required this.unreadCount,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      chatRoomId: json['chatRoomId'],
      type: json['type'],
      otherNickname: json['otherNickname'],
      otherProfileImageUrl: json['otherProfileImageUrl'],
      sharePostId: json['sharePostId'],
      chatRoomName: json['chatRoomName'],
      imageUrl: json['imageUrl'],
      lastMessage: json['lastMessage'] ?? '',
      lastSentAt: json['lastSentAt'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
