import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/chat/chat_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/protected_image.dart';
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
  late String currentRoomName;
  final TextEditingController _roomNameController = TextEditingController();
  String? selectedUser;
  List<Map<String, dynamic>> _participants = [];
  int? myMemberId;
  bool isAdmin = false;
  bool isGroupChatRoom = false;
  File? _selectedImageFile;

  // ✅ 추가: 이미지/이름 분기용
  String? groupImageUrl;
  String? otherImageUrl;
  String? otherNickname;

  @override
  void initState() {
    super.initState();
    currentRoomName = widget.roomName;
    _roomNameController.text = currentRoomName;
    _loadParticipants();
    _checkChatRoomTypeAndInfo();
  }

  void _checkChatRoomTypeAndInfo() async {
    try {
      final detail = await fetchChatRoomDetail(widget.chatRoomId);
      setState(() {
        isGroupChatRoom = detail.type == 'GROUP';
        groupImageUrl = detail.imageUrl;
        otherImageUrl = detail.otherProfileImageUrl;
        otherNickname = detail.otherNickname;
      });
    } catch (e) {
      debugPrint('❌ 채팅방 정보 조회 실패: $e');
    }
  }

  void _loadParticipants() async {
    try {
      final members = await fetchChatRoomMembers(widget.chatRoomId);
      final prefs = await SharedPreferences.getInstance();
      myMemberId = prefs.getInt('memberId');
      setState(() {
        _participants = members;
        isAdmin = _participants.any((p) =>
        p['memberId'] == myMemberId &&
            (p['admin'].toString() == '1' || p['admin'].toString().toLowerCase() == 'true'));
      });
    } catch (e) {
      debugPrint('❌ 멤버 불러오기 실패: $e');
    }
  }

  void _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImageFile = File(picked.path));
      try {
        await updateGroupChatRoom(
          chatRoomId: widget.chatRoomId,
          chatRoomName: currentRoomName,
          imageFile: _selectedImageFile,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 수정되었습니다.')),
        );
      } catch (e) {
        debugPrint('❌ 이미지 수정 실패: $e');
      }
    }
  }

  void _showEditNameDialog() {
    final tempController = TextEditingController(text: currentRoomName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('채팅방 이름 수정'),
        content: TextField(controller: tempController),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              final newName = tempController.text;
              await updateGroupChatRoom(
                chatRoomId: widget.chatRoomId,
                chatRoomName: newName,
                imageFile: _selectedImageFile,
              );
              setState(() => currentRoomName = newName);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('채팅방 이름이 수정되었습니다.')),
              );
            },
            child: const Text('저장'),
          )
        ],
      ),
    );
  }

  void _copyInviteLink() async {
    try {
      final inviteData = await fetchInviteLink(widget.chatRoomId);
      final inviteLink = inviteData['inviteLink'] ?? '';
      if (inviteLink.isNotEmpty) {
        Clipboard.setData(ClipboardData(text: inviteLink));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('초대 링크가 복사되었습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('초대 링크 복사 실패: $e')),
      );
    }
  }

  void _showBanDialog(int memberId, String nickname) {
    showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        content: '$nickname 님을 추방하시겠습니까?',
        confirmText: '추방',
        cancelText: '취소',
        onConfirm: () => _banMember(memberId),
      ),
    );
  }

  void _banMember(int memberId) async {
    try {
      await banChatRoomMember(
        chatRoomId: widget.chatRoomId,
        memberId: memberId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자를 추방했습니다.')),
      );
      _loadParticipants(); // 리스트 새로고침
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('추방 실패: $e')),
      );
    }
  }

  void _leaveChatRoom() async {
    try {
      await leaveChatRoom(widget.chatRoomId);
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
            (_) => false,
      );
    } catch (e) {
      debugPrint('❌ 채팅방 나가기 실패: $e');
    }
  }

  void _showSimpleLeaveDialog() {
    showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        content: '채팅방을 나가시겠습니까?',
        confirmText: '예',
        cancelText: '아니오',
        onConfirm: _leaveChatRoom,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: AppTheme.primaryPurple),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: GestureDetector(
              onTap: isAdmin && isGroupChatRoom ? _pickImageFromGallery : null,
              child: _selectedImageFile != null
                  ? CircleAvatar(
                radius: 40,
                backgroundImage: FileImage(_selectedImageFile!),
              )
                  : isGroupChatRoom && groupImageUrl != null && groupImageUrl!.isNotEmpty
                  ? CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(groupImageUrl!),
              )
                  : !isGroupChatRoom && otherImageUrl != null && otherImageUrl!.isNotEmpty
                  ? CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(otherImageUrl!),
              )
                  : const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
                child: Icon(Icons.group, color: Colors.white, size: 30),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isGroupChatRoom ? currentRoomName : (otherNickname ?? currentRoomName),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              if (isAdmin && isGroupChatRoom)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: _showEditNameDialog,
                )
            ],
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Text('대화 상대', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _participants.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 8,
                  ),
                    itemBuilder: (_, index) {
                      final p = _participants[index];
                      final img = p['profileImageUrl'];
                      final memberId = p['memberId'];
                      final nickname = p['nickname'] ?? '알 수 없음';

                      final url = img != null && img.isNotEmpty
                          ? 'http://10.0.2.2:8080$img?t=${DateTime.now().millisecondsSinceEpoch}'
                          : null;

                      final isCurrentUser = memberId == myMemberId;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          url != null
                              ? ProtectedImage(imageUrl: url)
                              : const CircleAvatar(radius: 12, backgroundColor: AppTheme.primaryPurple),
                          const SizedBox(width: 8),
                          Text(nickname),
                          const SizedBox(width: 10),
                          if (isGroupChatRoom && isAdmin && !isCurrentUser)
                            TextButton(
                              onPressed: () => _showBanDialog(memberId, nickname),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                '추방',
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              ),
                            ),
                        ],
                      );
                    }
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _copyInviteLink,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
                      child: const Text('초대링크 복사'),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: _showSimpleLeaveDialog,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('채팅방 나가기'),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
