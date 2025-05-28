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
    // 더미 데이터 (최신 메시지가 아래에 있도록 순서 조정)
  ].reversed.toList();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 초기 스크롤 위치를 맨 아래로 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: _messageController.text.trim(),
            isMe: true,
            time: DateTime.now(),
            readCount: 1,
          ),
        );
        _messageController.clear();
      });
      // 메시지가 추가된 후 스크롤을 가장 아래로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
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
              '상대방 아이디',
              style: TextStyle(color: AppTheme.textPurple, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPurple),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPurple,),
            onPressed: () {
              // 더보기 기능 구현
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildChatMessage(message);
                    },
                  ),
                ),
              ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: Column(
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: message.isMe ? AppTheme.lightPink.withOpacity(0.8) : AppTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(color: message.isMe ? AppTheme.textPurple : Colors.white),
                  ),
                ),
                Row(
                  mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (message.isMe && message.readCount > 0)
                      Text(
                        '${message.readCount}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    if (message.isMe && message.readCount > 0)
                      const SizedBox(width: 4),
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
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
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
            icon: Padding(
              padding: const EdgeInsets.only(right: 6.0,bottom: 6.0),
              child: const Icon(Icons.add_photo_alternate, color: AppTheme.textPurple),
            ),
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
            icon: const Icon(Icons.send, color: AppTheme.textPurple),
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