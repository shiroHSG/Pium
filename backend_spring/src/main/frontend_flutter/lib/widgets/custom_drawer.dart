import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/auth_services.dart';
import '../pages/sharing_page/sharing_page.dart';
import '../pages/calendar_page/calendar_page.dart';
import '../pages/community/community_page.dart';

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
              leading: const Icon(Icons.group),
              title: const Text('커뮤니티'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CommunityPage()),
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
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('내 활동'),
              onTap: () {
                Navigator.pop(context);
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
                Navigator.pop(context); // 드로어 닫기

                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      contentPadding: EdgeInsets.zero,
                      content: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '로그아웃 하시겠습니까?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    bool success = await AuthService().logout();
                                    Navigator.of(dialogContext).pop(); // 다이얼로그 닫기

                                    if (success) {
                                      onLoginStatusChanged(false); // 부모 위젯에 로그아웃 알림
                                    } else {
                                      showDialog(
                                        context: dialogContext,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('로그아웃 실패'),
                                            content: const Text('토큰이 없습니다. 다시 로그인해주세요.'),
                                            actions: [
                                              TextButton(
                                                child: const Text('확인'),
                                                onPressed: () => Navigator.of(context).pop(),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFde95ba),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  ),
                                  child: const Text(
                                    '예',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFde95ba),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  ),
                                  child: const Text(
                                    '아니오',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}