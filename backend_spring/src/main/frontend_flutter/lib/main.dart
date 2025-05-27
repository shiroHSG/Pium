import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/baby_record/baby_record_page.dart';
import 'package:frontend_flutter/pages/search/people_search_page.dart';
import 'package:frontend_flutter/pages/my_page/my_page.dart';
import 'package:frontend_flutter/widgets/custom_app_bar.dart';
import 'package:frontend_flutter/widgets/custom_bottom_bar.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/widgets/custom_drawer.dart';
import 'package:frontend_flutter/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '피움 앱',
      theme: AppTheme.lightTheme,
      home: const Login(),
      routes: {
        '/home': (context) => const MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onLoginStatusChanged(bool status) {
    setState(() {
      _isLoggedIn = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        onMenuPressed: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      endDrawer: CustomDrawer(
        onItemSelected: _onItemTapped,
        onLoginStatusChanged: _onLoginStatusChanged,
        isLoggedIn: _isLoggedIn,
      ),
      body: _getPageContent(_selectedIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _getPageContent(int index) {
    final double screenWidth = MediaQuery.of(context).size.width;

    switch (index) {
      case 0: // 홈 화면
        return SingleChildScrollView(
          child: Column(
            children: [
              // "아이 사진" 및 "이름" 박스
              Padding(
                padding: const EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 40.0),
                child: Container(
                  width: screenWidth,
                  height: 250,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                  decoration: BoxDecoration(
                    color: AppTheme.lightPink,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '아이\n사진',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '이름',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: AppTheme.textPurple,
                                ),
                              ),
                              Text(
                                'YY-MM-DD / 00cm / 00kg',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textPurple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'OO이는 생후 4개월이에요. 팔을 뻗어서 물체를 잡으려고 해요.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              // 캘린더 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                  decoration: BoxDecoration(
                    color: AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '19일',
                              style: TextStyle(
                                color: AppTheme.textPurple,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '• 태하 예방접종 - 14:00',
                              style: TextStyle(fontSize: 14),
                            ),
                            const Text(
                              '• 태하아빠 - 회의 15:00',
                              style: TextStyle(fontSize: 14),
                            ),
                            const Text(
                              '• 가족 외식 - 20:00',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 인기 게시글 제목
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Divider(
                      color: AppTheme.textPurple,
                      thickness: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    child: Text(
                      '인기 게시글',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: AppTheme.textPurple,
                      thickness: 1,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              // "인기 게시글"을 위한 플레이스홀더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: screenWidth - (16.0 * 2),
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Center(child: Text('인기 게시글 내용 들어갈 자리')),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.arrow_forward_ios, color: AppTheme.textPurple),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case 1: // 육아일지 페이지
        return const BabyRecordPage();
      case 2: // 채팅 페이지
        return const Center(child: Text('채팅 페이지 내용'));
      case 3: // 검색 페이지 (사람 찾기 페이지)
        return const PeopleSearchPage();
      case 4: // 마이 페이지
        return const MyPage(); // MyPage를 반환
      default:
        return const Center(child: Text('알 수 없는 페이지'));
    }
  }
}