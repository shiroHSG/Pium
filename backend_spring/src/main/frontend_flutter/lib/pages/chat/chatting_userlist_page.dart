import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool isEditing = false;
  late String currentRoomName;
  final TextEditingController _roomNameController = TextEditingController();
  String? selectedUser;

  List<Map<String, dynamic>> _participants = [];

  int? myMemberId;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    currentRoomName = widget.roomName;
    _roomNameController.text = currentRoomName;
    _loadParticipants();  // 멤버 불러오기
  }

  // 채팅방 멤버 불러오기
  void _loadParticipants() async {
    try {
      final members = await fetchChatRoomMembers(widget.chatRoomId);

      final prefs = await SharedPreferences.getInstance();
      myMemberId = prefs.getInt('memberId'); // 토큰에서 파싱해서 저장

      // 각 멤버에 대한 로그 출력
      for (var p in members) {
        print('👀 체크 중: id=${p['memberId']}, isAdmin=${p['isAdmin']} (${p['isAdmin'].runtimeType})');
      }

      setState(() {
        _participants = members;

        isAdmin = _participants.any((p) {
          final idMatch = p['memberId'] == myMemberId;
          final isAdminValue = p['admin'].toString(); // 문자열 비교
          return idMatch && (isAdminValue == '1' || isAdminValue.toLowerCase() == 'true');
        });

        print('🔥 최종 isAdmin: $isAdmin'); // 확인용 로그
      });
    } catch (e) {
      debugPrint('❌ 멤버 불러오기 실패: $e');
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

  // 채팅방 나가기
  void _leaveChatRoom() async {
    try {
      await leaveChatRoom(widget.chatRoomId); // 서버에 나가기 요청
      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()), // 홈화면 또는 채팅 리스트
            (route) => false,
      );
    } catch (e) {
      debugPrint('❌ 채팅방 나가기 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅방 나가기에 실패했습니다.')),
        );
      }
    }
  }

  // 채팅방 삭제하기
  void _deleteChatRoom(int chatRoomId) async {
    try {
      await deleteGroupChatRoom(chatRoomId); // 삭제 요청
      debugPrint('채팅방 삭제 완료');

      if (!context.mounted) return; // context가 살아있는지 체크

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
            (route) => false,
      );
    } catch (e) {
      debugPrint('❌ 채팅방 삭제 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅방 삭제에 실패했습니다.')),
        );
      }
    }
  }

  // 일반 사용자 채팅방 나가기 모달창
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

  // 방장 채팅방 나가기
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

  // 방장 위임
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
                  ..._participants.map((p) {
                    final nickname = p['nickname'] ?? '알 수 없음';
                    final memberId = p['memberId'].toString(); // 선택된 사용자 ID
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
                      Navigator.pop(context); // 위임 팝업 닫기

                      try {
                        // 문자열 selectedUser → 정수로 변환
                        final newAdminId = int.parse(selectedUser!);
                        await delegateAdmin(widget.chatRoomId, newAdminId);

                        _showDelegationCompleteDialog(
                          _participants.firstWhere((p) => p['memberId'].toString() == selectedUser)['nickname'],
                        );
                      } catch (e) {
                        debugPrint('❌ 방장 위임 실패: $e');
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

  // 방장위임 후 채팅방 나가기
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

// ✅ 방장일 때 멤버 추방 다이얼로그
  void _showBanConfirmDialog(Map<String, dynamic> participant) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        content: '${participant['nickname']}님을 추방하시겠습니까?',
        confirmText: '추방',
        cancelText: '취소',
        onConfirm: () => _banUser(participant),
      ),
    );
  }

// ✅ 추방 처리 함수
  void _banUser(Map<String, dynamic> participant) async {
    final int memberId = participant['memberId'];
    try {
      await banChatRoomMember(
        chatRoomId: widget.chatRoomId,
        memberId: memberId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${participant['nickname']}님을 추방했습니다.')),
      );
      _loadParticipants(); // 멤버 리스트 새로고침
    } catch (e) {
      debugPrint('❌ 추방 실패: \$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 추방에 실패했습니다.')),
        );
      }
    }
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
                  itemCount: _participants.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final participant = _participants[index];
                    final imagePath = participant['profileImageUrl'];
                    final fullImageUrl = (imagePath != null && imagePath.isNotEmpty)
                        ? 'http://10.0.2.2:8080${imagePath.startsWith('/') ? imagePath : '/$imagePath'}?t=${DateTime.now().millisecondsSinceEpoch}'
                        : null;

                    return Row(
                      children: [
                        fullImageUrl != null
                            ? ProtectedImage(imageUrl: fullImageUrl)
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
                      onPressed: _copyInviteLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('초대링크 복사'),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: () {
                        print('🔴 현재 isAdmin 값: $isAdmin');
                        if (isAdmin) {
                          _showLeaveConfirmDialog(); // 방장만 삭제/위임 가능
                        } else {
                          _showSimpleLeaveDialog(); // 일반 멤버는 단순 나가기만
                        }
                      },
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
