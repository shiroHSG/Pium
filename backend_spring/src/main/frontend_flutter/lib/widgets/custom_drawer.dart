import 'package:flutter/material.dart';

import '../pages/login.dart';

class CustomDrawer extends StatelessWidget {
  final ValueChanged<int> onItemSelected;
  final ValueChanged<bool> onLoginStatusChanged; // 로그인 상태 변경 콜백 추가
  final bool isLoggedIn; // 로그인 상태를 나타내는 변수 추가

  const CustomDrawer({
    Key? key,
    required this.onItemSelected,
    required this.onLoginStatusChanged, // 새로 추가된 필수 인자
    required this.isLoggedIn, // 새로 추가된 필수 인자
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
            SizedBox(
              height: 120.0,
              child: const DrawerHeader(
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
            // 로그인 상태에 따른 조건부 렌더링
            if (isLoggedIn) ...[ // 로그인 되어 있을 때만 표시할 메뉴
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
                onTap: () {
                  Navigator.pop(context);
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
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('캘린더'),
                onTap: () {
                  Navigator.pop(context);
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
                  Navigator.pop(context); // Drawer 닫기

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
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(); // 팝업 닫기
                                      onLoginStatusChanged(false); // 로그인 상태를 false로 변경
                                      // TODO: 실제 로그아웃 처리 (예: SharedPreferences 초기화)

                                      // 로그인 페이지로 이동 (홈 페이지 스택 제거)
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const Login()),
                                            (Route<dynamic> route) => false,
                                      );
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
                                      Navigator.of(dialogContext).pop(); // 팝업 닫기
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
            ] else ...[ // 로그아웃 되어 있을 때만 표시할 메뉴
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('로그인'),
                onTap: () {
                  Navigator.pop(context); // Drawer 닫기
                  // 로그인 페이지로 이동
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                        (Route<dynamic> route) => false,
                  );
                },
              ),
              // 여기에 로그아웃 상태에서 보여줄 다른 메뉴들을 추가할 수 있습니다.
              // 예: 회원가입 등
            ],
          ],
        ),
      ),
    );
  }
}