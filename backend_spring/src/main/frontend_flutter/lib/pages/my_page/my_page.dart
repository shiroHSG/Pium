import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/auth/auth_services.dart';
import 'package:frontend_flutter/screens/my_page/my_page_ui.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String nickname = '로딩 중...';
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final data = await AuthService().fetchMemberInfo();
    if (data != null && mounted) {
      final imagePath = data['profileImageUrl'];
      final fullImageUrl = (imagePath != null && imagePath.isNotEmpty)
          ? imagePath
          : null;

      setState(() {
        nickname = data['nickname'] ?? data['email'] ?? '알 수 없음';
        profileImageUrl = fullImageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyPageUI(
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      onProfileUpdated: _loadUserInfo,
    );
  }
}
