import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/screens/chatting/chatting_message_page_ui.dart';
import 'package:frontend_flutter/models/chat/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/chat/chat_service.dart';
import '../../models/webSocket/connectWebSocket.dart';
import 'chatting_userlist_page.dart';
import '../../models/chat/chatroom.dart'; // ChatRoom import 잊지 말기

class ChatRoomPage extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatRoomPage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  int? myId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      myId = prefs.getInt('memberId');

      if (myId == null) throw Exception('로그인된 사용자 ID가 없습니다.');

      final messages = await fetchMessages(
        chatRoomId: widget.chatRoom.chatRoomId,
        currentUserId: myId!,
      );

      setState(() {
        _messages.addAll(messages);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('❌ 메시지 불러오기 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _subscribeMessages() async {
    if (myId == null) {
      final prefs = await SharedPreferences.getInstance();
      myId = prefs.getInt('memberId');
      if (myId == null) {
        print('❌ 구독 실패: 사용자 ID가 없습니다.');
        return;
      }
    }

    subscribeChatRoomMessages(widget.chatRoom.chatRoomId, (data) {
      final message = ChatMessage.fromJson(data, myId!);
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await sendMessageToServer(
        chatRoomId: widget.chatRoom.chatRoomId,
        content: text,
        senderId: myId!,
      );
      _scrollToBottom();
    } catch (e) {
      print('❌ 메시지 전송 실패: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  // ✅ 추가된 부분: 채팅방 이름 반환
  String get chatTitle {
    final type = widget.chatRoom.type;
    if (type == 'DIRECT' || type == 'SHARE') {
      return widget.chatRoom.otherNickname ?? '채팅방';
    } else if (type == 'GROUP') {
      return widget.chatRoom.chatRoomName ?? '그룹 채팅방';
    }
    return '채팅방';
  }

  // ✅ 추가된 부분: 채팅방 이미지 URL 반환
  String? get chatImageUrl {
    final type = widget.chatRoom.type;
    if (type == 'DIRECT' || type == 'SHARE') {
      return widget.chatRoom.otherProfileImageUrl;
    } else if (type == 'GROUP') {
      return widget.chatRoom.imageUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
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
                  image: (chatImageUrl != null && chatImageUrl!.isNotEmpty)
                      ? DecorationImage(
                    image: NetworkImage(chatImageUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                  color: Colors.grey[300],
                ),
                child: (chatImageUrl == null || chatImageUrl!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey, size: 20)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                chatTitle,
                style: const TextStyle(
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
                      roomName: chatTitle,
                      chatRoomId: widget.chatRoom.chatRoomId,
                      participants: [],
                    ),
                  ),
                );
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
