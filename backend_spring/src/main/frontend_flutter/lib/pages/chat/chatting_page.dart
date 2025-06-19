import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/screens/chatting/chatting_page_ui.dart';
import 'dart:convert';

import '../../models/chat/chat_service.dart';
import '../../models/chat/chatroom.dart';
import 'chat_room_message_page.dart';

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
      _loadChatRooms(); // ✅ 채팅방 목록 다시 불러오기
    }
  }

  void _startNewChat() {
    print('새 $_selectedMode 시작');
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
