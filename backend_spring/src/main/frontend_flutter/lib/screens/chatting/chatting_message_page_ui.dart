import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/models/chat/message.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../pages/chat/invite_modal.dart';

class ChattingMessagePageUI extends StatelessWidget {
  final List<ChatMessage> messages;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final VoidCallback onSend;

  const ChattingMessagePageUI({
    super.key,
    required this.messages,
    required this.messageController,
    required this.scrollController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return _buildChatMessage(context, message);
                  },
                  reverse: true,
                ),
              ),
            ],
          ),
        ),
        _buildTextComposer(),
      ],
    );
  }

  Widget _buildChatMessage(BuildContext context, ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: message.senderProfileImageUrl.isNotEmpty
                        ? NetworkImage(message.senderProfileImageUrl)
                        : null,
                    child: message.senderProfileImageUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white, size: 20)
                        : null,
                  ),
                ],
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: message.isMe ? AppTheme.lightPink.withOpacity(0.8) : AppTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Linkify(
                    text: message.content,
                    onOpen: (link) async {
                      final uri = Uri.tryParse(link.url);
                      if (uri != null &&
                          uri.pathSegments.length >= 3 &&
                          uri.pathSegments[1] == 'invite') {
                        final inviteCode = uri.pathSegments[2];
                        showDialog(
                          context: context,
                          builder: (_) => InviteModal(inviteCode: inviteCode),
                        );
                      } else {
                        if (await canLaunchUrl(uri!)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                    style: TextStyle(color: message.isMe ? AppTheme.textPurple : Colors.white),
                    linkStyle: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    // if (message.isMe && message.unreadCount > 0)
                    //   Text(
                    //     '${message.unreadCount}',
                    //     style: const TextStyle(fontSize: 10, color: Colors.grey),
                    //   ),
                    if (message.isMe && message.unreadCount > 0)
                      const SizedBox(width: 4),
                    Text(
                      DateFormat('a h:mm').format(message.sentAt),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    // if (!message.isMe && message.unreadCount > 0)
                    //   Text(
                    //     '${message.unreadCount}',
                    //     style: const TextStyle(fontSize: 10, color: Colors.grey),
                    //   ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Padding(
              padding: EdgeInsets.only(right: 6.0, bottom: 6.0),
              child: Icon(Icons.add_photo_alternate, color: AppTheme.textPurple),
            ),
            onPressed: () {
              // 이미지 첨부 기능 구현
            },
          ),
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration.collapsed(
                hintText: '메시지를 입력하세요...',
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.textPurple),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
