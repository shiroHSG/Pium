import 'package:flutter/material.dart';
import '../../models/chat/chat_service.dart';
import '../../screens/chatting/invite_modal_ui.dart';
import 'chat_room_message_page.dart';

class InviteModal extends StatefulWidget {
  final String inviteCode;
  const InviteModal({super.key, required this.inviteCode});

  @override
  State<InviteModal> createState() => _InviteModalState();
}

class _InviteModalState extends State<InviteModal> {
  bool _loading = true;
  bool _joining = false;
  String? _chatRoomName;
  bool? _requirePassword;
  String? _error;
  final TextEditingController _pwController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkInviteCode();
  }

  Future<void> _checkInviteCode() async {
    try {
      final result = await checkInviteCode(widget.inviteCode);
      _chatRoomName = result['chatRoomName'];
      _requirePassword = result['requirePassword'];
      _loading = false;

      // 자동 입장
      if (_requirePassword == false) {
        _enterAndGo();
      } else {
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _enterAndGo({String? password}) async {
    try {
      setState(() => _joining = true);
      final chatRoomId = await enterChatRoomViaInvite(
        inviteCode: widget.inviteCode,
        password: password,
      );

      if (context.mounted) {
        Navigator.pop(context); // 모달 닫기
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomPage(chatRoomId: chatRoomId),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('입장 실패: $e')),
        );
      }
    } finally {
      setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_error != null) return Center(child: Text('❌ 오류: $_error'));

    if (_requirePassword == true) {
      return InviteModalUI(
        chatRoomName: _chatRoomName ?? '초대된 채팅방',
        passwordController: _pwController,
        isLoading: _joining,
        onCancel: () => Navigator.pop(context),
        onConfirm: () => _enterAndGo(password: _pwController.text.trim()),
      );
    }

    return const SizedBox.shrink();
  }
}
