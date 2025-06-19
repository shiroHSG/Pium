import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/screens/chatting/chatting_message_page_ui.dart';
import 'package:frontend_flutter/models/chat_message.dart';

import 'chatting_userlist_page.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({Key? key}) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: '안녕하세요!',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 1)),
      readCount: 1,
    ),
    ChatMessage(
      text: '네, 안녕하세요.',
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
      readCount: 0,
    ),
    ChatMessage(
      text: '오늘 날씨가 좋네요.',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      readCount: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: _messageController.text.trim(),
          isMe: true,
          time: DateTime.now(),
          readCount: 1,
        ));
        _messageController.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      // 서버 전송 로직 추가 예정
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
              style: TextStyle(
                color: AppTheme.textPurple,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPurple),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPurple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChattingUserlistPage(
                    roomName: '육아 친구들',
                    onCopyInviteLink: () {
                      // TODO: 클립보드 복사 로직 구현
                      print('초대링크 복사');
                    },
                    onLeaveChatRoom: () {
                      // TODO: 채팅방 나가기 로직 구현
                      print('채팅방 나가기');
                    },
                    participants: [
                      {'nickname': '작성자 아이디', 'profileImageUrl': null},
                      {'nickname': '참여자1', 'profileImageUrl': null},
                      {'nickname': '참여자2', 'profileImageUrl': null},
                      {'nickname': '참여자3', 'profileImageUrl': null},
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ChattingMessagePageUI(
        messages: _messages,
        messageController: _messageController,
        scrollController: _scrollController,
        onSend: _sendMessage,
      ),
    );
  }
}
