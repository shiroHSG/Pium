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
                      onPressed: onCopyInviteLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('초대링크 복사'),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: onLeaveChatRoom,
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
