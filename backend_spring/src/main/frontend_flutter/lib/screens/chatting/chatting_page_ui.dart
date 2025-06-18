import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart';

import '../../models/chat/chatroom.dart';

class ChattingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String selectedMode;  //선택모드 ->  type
  final List<String> modeOptions;
  final ValueChanged<String> onModeSelected;  //나눔, 메시지

  const ChattingAppBar({
    Key? key,
    required this.selectedMode,
    required this.modeOptions,
    required this.onModeSelected,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text(
        '채팅',
        style: TextStyle(color: AppTheme.textPurple, fontWeight: FontWeight.bold),
      ),
      actions: [
        PopupMenuButton<String>(
          offset: const Offset(0, 40),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          onSelected: onModeSelected,
          itemBuilder: (BuildContext context) {
            return modeOptions.map((String option) {
              return PopupMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(color: AppTheme.textPurple),
                ),
              );
            }).toList();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  selectedMode,
                  style: const TextStyle(
                    color: AppTheme.textPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.textPurple,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChattingListItem extends StatelessWidget {
  final ChatRoom chatRoom;
  final VoidCallback onTap;

  const ChattingListItem({
    Key? key,
    required this.chatRoom,
    required this.onTap,
  }) : super(key: key);

  String _formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      return DateFormat.Hm().format(dateTime); // 예: 14:22
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = chatRoom.imageUrl ??
        chatRoom.otherProfileImageUrl ?? ''; // 없으면 공백

    final name = chatRoom.chatRoomName ?? chatRoom.otherNickname ?? '이름 없음';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: profileImage.isNotEmpty
                  ? NetworkImage(profileImage)
                  : null,
              backgroundColor: Colors.grey[300],
              child: profileImage.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chatRoom.lastMessage,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(chatRoom.lastSentAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (chatRoom.unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${chatRoom.unreadCount}',
                      style:
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChattingFloatingActionButton extends StatelessWidget {
  final String selectedMode;
  final VoidCallback onPressed;

  const ChattingFloatingActionButton({
    Key? key,
    required this.selectedMode,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppTheme.primaryPurple,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}