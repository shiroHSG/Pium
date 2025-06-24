// widgets/linkify_text.dart
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../pages/chat/invite_modal.dart';

class LinkifyText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const LinkifyText({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return Linkify(
      text: text,
      onOpen: (link) async {
        final uri = Uri.tryParse(link.url);
        if (uri != null &&
            uri.pathSegments.length >= 3 &&
            uri.pathSegments[1] == 'invite') {
          final inviteCode = uri.pathSegments[2];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InviteModal(inviteCode: inviteCode),
            ),
          );
        } else {
          if (await canLaunchUrl(uri!)) {
            await launchUrl(uri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('링크를 열 수 없습니다.')),
            );
          }
        }
      },
      style: style ?? DefaultTextStyle.of(context).style, // ✅ 기본 스타일 직접 지정
      linkStyle: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
    );
  }
}
