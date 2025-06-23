import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/screens/chatting/chatting_page_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../models/chat/chat_service.dart';
import '../../models/chat/chatroom.dart';
import '../../models/util/parse_date_time.dart';
import '../../models/webSocket/connectWebSocket.dart';
import 'chat_room_message_page.dart';
import 'create_chatting_dialog.dart';

class ChattingPage extends StatefulWidget {
  const ChattingPage({Key? key}) : super(key: key);

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  String _selectedMode = '나눔/품앗이';
  final List<String> _modeOptions = ['나눔/품앗이', '채팅'];

  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
    _subscribeSummaryOnEnter();
  }

  Future<void> _loadChatRooms() async {
    try {
      final rooms = await fetchChatRooms();
      setState(() {
        _chatRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 채팅방 불러오기 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _subscribeSummaryOnEnter() async {
    final prefs = await SharedPreferences.getInstance();
    final myId = prefs.getInt('memberId');

    if (myId == null) {
      print('❌ SharedPreferences에 memberId 없음');
      return;
    }

    subscribeSummary(myId, (data) {
      final int chatRoomId = data['chatRoomId'];
      final String lastMessage = data['lastMessage'];
      final int unreadCount = data['unreadCount'];
      final DateTime? lastSentAt = parseDateTime(data['lastSentAt']);

      setState(() {
        final index = _chatRooms.indexWhere((room) => room.chatRoomId == chatRoomId);
        if (index != -1) {
          final oldRoom = _chatRooms[index];
          _chatRooms[index] = ChatRoom(
            chatRoomId: chatRoomId,
            type: oldRoom.type,
            otherNickname: oldRoom.otherNickname,
            otherProfileImageUrl: oldRoom.otherProfileImageUrl,
            sharePostId: oldRoom.sharePostId,
            chatRoomName: oldRoom.chatRoomName,
            imageUrl: oldRoom.imageUrl,
            lastMessage: lastMessage,
            lastSentAt: lastSentAt,
            unreadCount: unreadCount,
          );
        }
      });
    });
  }

  void _handleModeSelection(String value) {
    setState(() {
      _selectedMode = value;
    });
    print('선택된 모드: $_selectedMode');
  }

  void _navigateToChatRoom(int chatRoomId) async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(chatRoomId: chatRoomId),
      ),
    );

    if (shouldRefresh == true) {
      _loadChatRooms(); // 채팅방 목록 다시 불러오기
    }
  }

  void _startNewChat() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const CreateChattingDialog(),
    );

    if (result == true) {
      _loadChatRooms(); // 생성 후 채팅방 목록 새로 불러오기
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredChatRooms = _chatRooms.where((room) {
      if (_selectedMode == '나눔/품앗이') {
        return room.type == 'SHARE';
      } else {
        return room.type == 'DIRECT' || room.type == 'GROUP';
      }
    }).toList();

    return Scaffold(
      appBar: ChattingAppBar(
        selectedMode: _selectedMode,
        modeOptions: _modeOptions,
        onModeSelected: _handleModeSelection,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredChatRooms.isEmpty
          ? const Center(child: Text('채팅방이 없습니다.'))
          : ListView.separated(
        itemCount: filteredChatRooms.length,
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          color: AppTheme.textPurple,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final room = filteredChatRooms[index];
          return ChattingListItem(
            chatRoom: room,
            onTap: () => _navigateToChatRoom(room.chatRoomId),
          );
        },
      ),
      floatingActionButton: ChattingFloatingActionButton(
        selectedMode: _selectedMode,
        onPressed: _startNewChat,
      ),
    );
  }
}
