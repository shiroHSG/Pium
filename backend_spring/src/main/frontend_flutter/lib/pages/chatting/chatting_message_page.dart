// chatting_message_page.dart
import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart'; // 시간 표시를 위해 import

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({Key? key}) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: '안녕하세요!', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 5)), readCount: 1),
    ChatMessage(text: '네, 안녕하세요.', isMe: true, time: DateTime.now().subtract(const Duration(minutes: 3)), readCount: 0),
    ChatMessage(text: '오늘 날씨가 좋네요.', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 1)), readCount: 1),
    // 더미 데이터
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: _messageController.text.trim(),
          isMe: true,
          time: DateTime.now(),
          readCount: 0,
        ));
        _messageController.clear();
      });
      // 실제 앱에서는 여기서 서버로 메시지를 전송하는 로직을 구현해야 합니다.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.grey, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '채팅 상대방',
              style: TextStyle(color: AppTheme.textPurple, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPurple),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // 알림 관련 기능 구현
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              // 더보기 기능 구현
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatMessage(message);
              },
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 15,
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: message.isMe ? AppTheme.primaryPurple.withOpacity(0.8) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(color: message.isMe ? Colors.white : Colors.black),
                  ),
                ),
                Row(
                  mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('a h:mm').format(message.time),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    if (!message.isMe && message.readCount > 0)
                      Text(
                        '${message.readCount}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    if (message.isMe && message.readCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '${message.readCount}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (message.isMe)
            const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate, color: AppTheme.textPurple),
            onPressed: () {
              // 이미지 첨부 기능 구현
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration.collapsed(
                hintText: '메시지를 입력하세요...',
              ),
              onSubmitted: (text) {
                _sendMessage();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.primaryPurple),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  final int readCount;

  ChatMessage({required this.text, required this.isMe, required this.time, required this.readCount});
}