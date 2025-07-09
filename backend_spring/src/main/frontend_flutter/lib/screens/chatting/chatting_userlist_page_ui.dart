import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/protected_image.dart';

class ChattingUserlistPageUI extends StatelessWidget {
  final String roomName;
  final bool isEditing;
  final TextEditingController roomNameController;
  final VoidCallback onToggleEdit;
  final List<Map<String, dynamic>> participants;
  final VoidCallback onCopyInviteLink;
  final VoidCallback onLeaveChatRoom;
  final VoidCallback? onLeaveWithDelegation;
  final bool isAdmin;
  final VoidCallback? onBanPressed;

  const ChattingUserlistPageUI({
    super.key,
    required this.roomName,
    required this.isEditing,
    required this.roomNameController,
    required this.onToggleEdit,
    required this.participants,
    required this.onCopyInviteLink,
    required this.onLeaveChatRoom,
    this.onLeaveWithDelegation,
    required this.isAdmin,
    this.onBanPressed,
  });

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
                      controller: roomNameController,
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
                    roomName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPurple,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: onToggleEdit,
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
                  itemCount: participants.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    final imagePath = participant['profileImageUrl'];
                    final fullImageUrl = (imagePath != null && imagePath.isNotEmpty)
                        ? imagePath
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 초대링크 복사 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onCopyInviteLink,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: Size.zero, // 최소 크기 해제
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('초대링크 복사', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 추방 버튼 (조건부 렌더링)
                    if (isAdmin && onBanPressed != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onBanPressed,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            minimumSize: Size.zero,
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('추방하기', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    if (isAdmin && onBanPressed != null) const SizedBox(width: 8),

                    // 나가기 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onLeaveChatRoom,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: Size.zero,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('채팅방 나가기', style: TextStyle(fontSize: 12)),
                      ),
                    ),
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
