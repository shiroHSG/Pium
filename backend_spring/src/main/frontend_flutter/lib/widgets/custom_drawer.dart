import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/auth_services.dart';
import '../pages/calendar_page/calendar_page.dart';
import '../pages/my_page/baby_profile/babyProfile_page.dart';
import '../pages/my_page/my_activity/my_activity_page.dart';
import '../pages/policy_page/policy_page.dart';
import '../pages/search/people_search_page.dart';
import '../pages/sharing_page/sharing_page.dart';
import 'confirm_dialog.dart';

class CustomDrawer extends StatelessWidget {
  final ValueChanged<int> onItemSelected;
  final ValueChanged<bool> onLoginStatusChanged;

  const CustomDrawer({
    Key? key,
    required this.onItemSelected,
    required this.onLoginStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.65,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 120.0,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFde95ba),
                ),
                child: Text(
                  '메뉴',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('홈'),
              onTap: () {
                Navigator.pop(context);
                onItemSelected(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('정보제공'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PolicyPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('육아일지'),
              onTap: () {
                Navigator.pop(context);
                onItemSelected(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('나눔 품앗이'),
              onTap: () async {
                Navigator.pop(context);

                // SharedPreferences에서 JWT 토큰 불러오기
                final prefs = await SharedPreferences.getInstance();
                final token = await prefs.getString('accessToken');
                print('[CustomDrawer] 전달할 token: $token');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SharingPage(token: token),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('채팅목록'),
              onTap: () {
                Navigator.pop(context);
                onItemSelected(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('사람찾기'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PeopleSearchPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('캘린더'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('내정보'),
              onTap: () {
                Navigator.pop(context);
                onItemSelected(4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.child_care),
              title: const Text('아이 정보'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BabyProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('내 활동'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyActivityPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('환경 설정'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    content: '로그아웃 하시겠습니까?',
                    onConfirm: () async {
                      bool success = await AuthService().logout();
                      if (success) {
                        onLoginStatusChanged(false);
                      } else {
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
              },
            ),
          ],
        ),
      ),
    );
  }
}