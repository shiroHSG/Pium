import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/chat/chat_service.dart';
import 'package:frontend_flutter/models/chat/chatroom.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/widgets/protected_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pages/chat/chat_room_message_page.dart';
import '../../pages/chat/invite_modal.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

Widget SharingDetailPageUI(
    BuildContext context,
    SharingItem item,
    int likeCount,
    bool isLiked,
    VoidCallback onLikePressed,
    ) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: AppTheme.primaryPurple,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
      ],
    ),
    body: Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                item.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 30, thickness: 1, color: Colors.grey),
              SizedBox(
                width: double.infinity,
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.imageUrl != null
                      ? ProtectedImage(
                    imageUrl: item.imageUrl!.startsWith('http')
                        ? item.imageUrl!
                        : 'http://10.0.2.2:8080${item.imageUrl!}',
                  )
                      : Container(
                    color: AppTheme.lightPink,
                    child: const Center(
                      child: Text(
                        '제품 이미지',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 13.0),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.authorId,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '작성일 : ${item.postDate}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: AppTheme.primaryPurple,
                              size: 20,
                            ),
                            onPressed: onLikePressed,
                          ),
                          Text('$likeCount'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          Text('${item.views}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Linkify(
                  text: item.content,
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
                  style: const TextStyle(fontSize: 14),
                  linkStyle: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleChatButtonPressed(context, item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  '채팅하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ✅ 분리된 함수
Future<void> _handleChatButtonPressed(BuildContext context, SharingItem item) async {
  try {
    final chatRoom = await createOrGetShareChatRoom(
      receiverId: item.authorMemberId,
      sharePostId: item.id,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(chatRoomId: chatRoom.chatRoomId),
      ),
    );
  } catch (e) {
    print('❌ 채팅방 열기 실패: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('채팅방을 여는 데 실패했습니다.')),
    );
  }
}