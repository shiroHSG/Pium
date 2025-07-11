import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/auth/auth_services.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../screens/my_page/setting_page/setting_page_ui.dart';
import 'change_password_page.dart';

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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            );
          }),
          buildSettingsButton('로그아웃', () {
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                content: '로그아웃 하시겠습니까?',
                onConfirm: () async {
                  // 1. ConfirmDialog에서 '예' 누르면 실행
                  bool success = await AuthService().logout();
                  if (success) {
                    // 2. 로그아웃 성공 시 로그인(처음)화면으로 이동
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    // 3. 실패시 에러 다이얼로그
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('로그아웃 실패'),
                        content: Text('토큰이 없습니다. 다시 로그인해주세요.'),
                      ),
                    );
                  }
                },
              ),
            );
          }),
          buildSettingsButton('회원 탈퇴', () {
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                content: '정말 회원 탈퇴하시겠습니까?\n탈퇴 시 모든 정보가 삭제됩니다.',
                onConfirm: () async {
                  // 1. 탈퇴 API 호출
                  bool success = await AuthService().deleteMember();
                  if (success) {
                    // 2. 탈퇴 성공 안내 다이얼로그
                    showDialog(
                      context: context,
                      barrierDismissible: false, // [확인] 누르기 전까지 닫히지 않게
                      builder: (context) => AlertDialog(
                        title: const Text('탈퇴 완료'),
                        content: const Text('회원 탈퇴가 완료되었습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // 3. [확인] 누르면 로그인(처음)화면으로 이동 (기존 라우트 모두 제거)
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login', (route) => false,
                              );
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // 4. 실패 시 에러 다이얼로그
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('탈퇴 실패'),
                        content: Text('탈퇴 처리에 실패했습니다. 잠시 후 다시 시도해주세요.'),
                      ),
                    );
                  }
                },
              ),
            );
          }),

          buildSettingsSectionTitle('앱 환경'),
          buildSettingsButton('알림 설정', () {
            // 추후 구현
          }),

          buildSettingsSectionTitle('기타'),
          buildSettingsButton('이용약관 보기', () {
            // 추후 구현
          }),
        ],
      ),
    );
  }
}
