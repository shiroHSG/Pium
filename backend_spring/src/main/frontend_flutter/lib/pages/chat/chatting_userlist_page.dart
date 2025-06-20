import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/protected_image.dart';
import '../home/home_page.dart';
import 'chatting_page.dart';

class ChattingUserlistPage extends StatefulWidget {
  final String roomName;
  final VoidCallback onCopyInviteLink;
  final VoidCallback onLeaveChatRoom;
  final List<Map<String, String?>> participants;

  const ChattingUserlistPage({
    Key? key,
    required this.roomName,
    required this.onCopyInviteLink,
    required this.onLeaveChatRoom,
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

  @override
  void initState() {
    super.initState();
    currentRoomName = widget.roomName;
    _roomNameController.text = currentRoomName;
  }

  void _deleteChatRoom() {
    // TODO: 실제 삭제 로직 API 연동

    debugPrint('채팅방 삭제');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MyHomePage(), // ✅ 메인 홈으로 이동
      ),
          (route) => false,
    );
  }

  void _showDelegationCompleteDialog(String nickname) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        content: '방장이 위임되었습니다.\n채팅방을 나가시겠습니까?',
        confirmText: '예',
        cancelText: '아니오',
        onConfirm: widget.onLeaveChatRoom,
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
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.participants.map((p) {
                    final nickname = p['nickname']!;
                    return RadioListTile<String>(
                      title: Text(nickname),
                      value: nickname,
                      groupValue: selectedUser,
                      onChanged: (value) => setState(() => selectedUser = value),
                      activeColor: AppTheme.primaryPurple,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedUser == null
                        ? null
                        : () {
                      Navigator.pop(context);
                      _showDelegationCompleteDialog(selectedUser!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('위임하기'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLeaveConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        content: '채팅방을 삭제 하시겠습니까?\n방장을 위임하시겠습니까?',
        confirmText: '삭제',
        cancelText: '방장 위임',
        onConfirm: _deleteChatRoom,
        onCancel: _showDelegationSelectDialog,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        elevation: 0,
        centerTitle: false,
        title: const Text('', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 70),
          const CircleAvatar(radius: 35, backgroundColor: Colors.grey),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isEditing
                      ? SizedBox(
                    width: 150,
                    child: TextField(
                      controller: _roomNameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPurple,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4),
                        border: InputBorder.none,
                      ),
                    ),
                  )
                      : Text(
                    currentRoomName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPurple,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (isEditing) {
                          currentRoomName = _roomNameController.text;
                        }
                        isEditing = !isEditing;
                      });
                    },
                    icon: Icon(
                      isEditing ? Icons.check : Icons.edit,
                      size: 20,
                      color: AppTheme.textPurple,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10.0, left: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '대화 상대',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPurple,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                GridView.builder(
                  padding: const EdgeInsets.only(left: 12.0, bottom: 15.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.participants.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final participant = widget.participants[index];
                    final imagePath = participant['profileImageUrl'];
                    final fullImageUrl = (imagePath != null && imagePath.isNotEmpty)
                        ? 'http://10.0.2.2:8080${imagePath.startsWith('/') ? imagePath : '/$imagePath'}?t=${DateTime.now().millisecondsSinceEpoch}'
                        : null;

                    return Row(
                      children: [
                        fullImageUrl != null
                            ? ProtectedImage(imageUrl: fullImageUrl, size: 24)
                            : const CircleAvatar(
                          radius: 12,
                          backgroundColor: AppTheme.primaryPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          participant['nickname'] ?? '알 수 없음',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPurple,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: widget.onCopyInviteLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('초대링크 복사'),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: _showLeaveConfirmDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('채팅방 나가기'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
