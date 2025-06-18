import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/screens/chatting/chatting_message_page_ui.dart';
import 'package:frontend_flutter/models/chat/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/chat/chat_service.dart';

class ChatRoomPage extends StatefulWidget {
  final int chatRoomId;

  const ChatRoomPage({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final myId = prefs.getInt('memberId');

      if (myId == null) {
        throw Exception('로그인된 사용자 ID가 없습니다.');
      }
      final messages = await fetchMessages(
        chatRoomId: widget.chatRoomId,
        currentUserId: myId,
      );
      setState(() {
        _messages.addAll(messages);
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } catch (e) {
      print('❌ 메시지 불러오기 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    // 자동 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    // ✅ 서버 전송 로직: 실제로 전송하고 응답 메시지로 갱신하고 싶다면 여기에 추가
    // try {
    //   await sendMessageToServer(widget.chatRoomId, text); // 함수는 직접 정의해야 함
    // } catch (e) {
    //   print('❌ 메시지 전송 실패: $e');
    //   // 오류 처리 로직 추가 (ex. 메시지 삭제 or 재시도 표시)
    // }
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
              '채팅방',
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
              // TODO: 더보기 기능
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ChattingMessagePageUI(
        messages: _messages,
        messageController: _messageController,
        scrollController: _scrollController,
        onSend: _sendMessage,
      ),
    );
  }
}
