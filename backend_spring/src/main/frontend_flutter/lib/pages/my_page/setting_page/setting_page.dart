import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import '../../../screens/my_page/setting_page/setting_page_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        elevation: 0,
        title: const Text('환경설정', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 50.0),
        children: [
          buildSettingsSectionTitle('계정'),
          buildSettingsButton('비밀번호 변경', () {
            print('비밀번호 변경');
          }),
          buildSettingsButton('로그아웃', () {
            print('로그아웃');
          }),
          buildSettingsButton('회원 탈퇴', () {
            print('회원 탈퇴');
          }),

          buildSettingsSectionTitle('앱 환경'),
          buildSettingsButton('다크모드 설정', () {
            print('다크모드 설정');
          }),
          buildSettingsButton('알림 설정', () {
            print('알림 설정');
          }),

          buildSettingsSectionTitle('기타'),
          buildSettingsButton('이용약관 보기', () {
            print('이용약관 보기');
          }),
        ],
      ),
    );
  }
}
