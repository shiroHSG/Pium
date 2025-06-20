class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  final int readCount;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    required this.readCount,
  });
}
