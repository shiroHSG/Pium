import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/chat/chat_service.dart';
import '../../screens/chatting/chatting_userlist_page_ui.dart';
import '../../widgets/confirm_dialog.dart';
import '../home/home_page.dart';

class ChattingUserlistPage extends StatefulWidget {
  final String roomName;
  final int chatRoomId;
  final List<Map<String, String?>> participants;

  const ChattingUserlistPage({
    Key? key,
    required this.roomName,
    required this.chatRoomId,
    required this.participants,
  }) : super(key: key);

  @override
  State<ChattingUserlistPage> createState() => _ChattingUserlistPageState();
}

class _ChattingUserlistPageState extends State<ChattingUserlistPage> {
  bool isEditing = false;
  late String currentRoomName;
  final TextEditingController _roomNameController = TextEditingController();
  String? selectedUser;
  List<Map<String, dynamic>> _participants = [];
  int? myMemberId;
  bool isAdmin = false;
  String? selectedBanUserId;

  @override
  void initState() {
    super.initState();
    currentRoomName = widget.roomName;
    _roomNameController.text = currentRoomName;
    _loadParticipants();
  }

  void _loadParticipants() async {
    try {
      final members = await fetchChatRoomMembers(widget.chatRoomId);
      final prefs = await SharedPreferences.getInstance();
      myMemberId = prefs.getInt('memberId');

      setState(() {
        _participants = members;
        isAdmin = _participants.any((p) {
          final idMatch = p['memberId'] == myMemberId;
          final isAdminValue = p['admin'].toString();
          return idMatch && (isAdminValue == '1' || isAdminValue.toLowerCase() == 'true');
        });
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅방 멤버를 불러오는 데 실패했습니다.')),
        );
      }
    }
  }

  void _copyInviteLink() {
    final inviteLink = 'https://yourapp.com/invite/${widget.chatRoomId}';
    Clipboard.setData(ClipboardData(text: inviteLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('초대 링크가 복사되었습니다.')),
    );
  }

  void _leaveChatRoom() async {
    try {
      await leaveChatRoom(widget.chatRoomId);
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
            (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅방 나가기에 실패했습니다.')),
        );
      }
    }
  }

  void _deleteChatRoom(int chatRoomId) async {
    try {
      await deleteGroupChatRoom(chatRoomId);
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
            (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅방 삭제에 실패했습니다.')),
        );
      }
    }
  }

  void _showSimpleLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        content: '채팅방을 나가시겠습니까?',
        confirmText: '예',
        cancelText: '아니오',
        onConfirm: _leaveChatRoom,
      ),
    );
  }

  void _showLeaveConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        content: '채팅방을 삭제 하시겠습니까?\n방장을 위임하시겠습니까?',
        confirmText: '삭제',
        cancelText: '방장 위임',
        onConfirm: () => _deleteChatRoom(widget.chatRoomId),
        onCancel: _showDelegationSelectDialog,
      ),
    );
  }

  void _showDelegationSelectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '누구에게 위임하시겠습니까?',
                    style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._participants.map((p) {
                    final nickname = p['nickname'] ?? '알 수 없음';
                    final memberId = p['memberId'].toString();
                    return RadioListTile<String>(
                      title: Text(nickname),
                      value: memberId,
                      groupValue: selectedUser,
                      onChanged: (value) => setState(() => selectedUser = value),
                      activeColor: AppTheme.primaryPurple,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedUser == null
                        ? null
                        : () async {
                      Navigator.pop(context);
                      try {
                        final newAdminId = int.parse(selectedUser!);
                        await delegateAdmin(widget.chatRoomId, newAdminId);
                        _showDelegationCompleteDialog(
                          _participants.firstWhere((p) => p['memberId'].toString() == selectedUser)['nickname'],
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('방장 위임에 실패했습니다.')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('위임하기'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDelegationCompleteDialog(String nickname) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        content: '방장이 위임되었습니다.\n채팅방을 나가시겠습니까?',
        confirmText: '예',
        cancelText: '아니오',
        onConfirm: _leaveChatRoom,
      ),
    );
  }

  void _showBanSelectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '누구를 추방하시겠습니까?',
                    style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._participants.where((p) => p['memberId'] != myMemberId).map((p) {
                    final nickname = p['nickname'] ?? '알 수 없음';
                    final memberId = p['memberId'].toString();
                    return RadioListTile<String>(
                      title: Text(nickname),
                      value: memberId,
                      groupValue: selectedBanUserId,
                      onChanged: (value) => setState(() => selectedBanUserId = value),
                      activeColor: AppTheme.primaryPurple,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedBanUserId == null
                        ? null
                        : () {
                      Navigator.pop(context);
                      final target = _participants.firstWhere((p) => p['memberId'].toString() == selectedBanUserId);
                      _banUser(target);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('추방하기'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _banUser(Map<String, dynamic> participant) async {
    final int memberId = participant['memberId'];
    try {
      await banChatRoomMember(chatRoomId: widget.chatRoomId, memberId: memberId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${participant['nickname']}님을 추방했습니다.')),
      );
      _loadParticipants();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 추방에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChattingUserlistPageUI(
      roomName: currentRoomName,
      isEditing: isEditing,
      roomNameController: _roomNameController,
      onToggleEdit: () {
        setState(() {
          if (isEditing) {
            currentRoomName = _roomNameController.text;
          }
          isEditing = !isEditing;
        });
      },
      participants: _participants,
      onCopyInviteLink: _copyInviteLink,
      onLeaveChatRoom: isAdmin ? _showLeaveConfirmDialog : _showSimpleLeaveDialog,
      onLeaveWithDelegation: _showDelegationSelectDialog,
      isAdmin: isAdmin,
      onBanPressed: isAdmin && _participants.any((p) => p['memberId'] != myMemberId)
          ? _showBanSelectDialog
          : null,
    );
  }
}
