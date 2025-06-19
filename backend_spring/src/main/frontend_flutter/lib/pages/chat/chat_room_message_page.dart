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

    try {
      final prefs = await SharedPreferences.getInstance();
      final myId = prefs.getInt('memberId');
      if (myId == null) throw Exception('로그인 정보 없음');

      final newMessage = await sendMessageToServer(
        chatRoomId: widget.chatRoomId,
        content: text,
        senderId: myId,
      );

      setState(() {
        _messages.add(newMessage);
      });

      // 자동 스크롤
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      print('❌ 메시지 전송 실패: $e');
      // 필요 시 토스트나 경고 처리
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // ✅ ChattingPage에게 '갱신 필요' 신호 전달
        return false; // ✅ 기본 Pop 동작 막기
      },
      child: Scaffold(
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
      ),
    );
  }
}
