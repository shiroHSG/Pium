// chatting_page.dart
import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/pages/chatting/chatting_message_page.dart';
import 'package:frontend_flutter/screens/chatting/chatting_page_ui.dart';

class ChattingPage extends StatefulWidget {
  const ChattingPage({Key? key}) : super(key: key);

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  String _selectedMode = '나눔/품앗이'; // 기본 선택
  final List<String> _modeOptions = ['나눔/품앗이', '채팅'];

  void _handleModeSelection(String value) {
    setState(() {
      _selectedMode = value;
    });
    print('선택된 모드: $_selectedMode');
  }

  void _navigateToChatRoom(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatRoomPage(),
      ),
    );
  }

  void _startNewChat() {
    print('새 $_selectedMode 시작');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChattingAppBar(
        selectedMode: _selectedMode,
        modeOptions: _modeOptions,
        onModeSelected: _handleModeSelection,
      ),
      body: ListView.separated(
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          color: AppTheme.textPurple,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          return ChattingListItem(
            index: index,
            selectedMode: _selectedMode,
            onTap: () => _navigateToChatRoom(index),
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