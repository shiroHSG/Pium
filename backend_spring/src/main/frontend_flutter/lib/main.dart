import 'package:flutter/material.dart';
import 'package:frontend_flutter/widgets/custom_app_bar.dart';
import 'package:frontend_flutter/widgets/custom_bottom_bar.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

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
      home: const MyHomePage(),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 여기에서 인덱스에 따라 다른 페이지로 이동하는 로직을 처리합니다.
    // 예를 들어:
    // if (index == 0) { Navigator.push(context, MaterialPageRoute(builder: (context) => RecordsPage())); }
    // if (index == 1) { Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())); }
    // if (index == 2) { Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage())); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: _getPageContent(_selectedIndex),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _getPageContent(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth - (16.0 * 2);

    switch (index) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            children: [
              // "아이 사진" 및 "이름" 박스
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 0.0, right: 16.0, bottom: 16.0),
                child: Container(
                  width: contentWidth,
                  height: 200,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
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
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '이름',
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '태하는 생후 4개월이에요.',
                                  style: TextStyle(
                                      color: AppTheme.textPurple,
                                      fontSize: 16),
                                ),
                                Text(
                                  '팔을 뻗어서 물체를 잡으려고 해요.',
                                  style: TextStyle(
                                      color: AppTheme.textPurple,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 스케줄 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Container(
                  width: contentWidth,
                  padding: const EdgeInsets.only(left: 40.0, top: 20.0, right: 20.0, bottom: 20.0),
                  decoration: BoxDecoration(
                    color: AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                      Text(
                        '• 태하 예방접종 - 14:00',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '• 태하아빠 - 회의 15:00',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '• 가족 외식 - 20:00',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 인기 게시글 제목
              Text( 
                '인기 게시글',
                style: TextStyle(
                  // color: AppTheme.textPurple,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              // "인기 게시글"을 위한 플레이스홀더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: contentWidth,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: const Center(child: Text('인기 게시글 내용 들어갈 자리')),
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
      case 1:
        return const Text('육아일지 페이지 내용');
      case 2:
        return const Text('채팅 페이지 내용');
      case 3:
        return const Text('검색 페이지 내용');
      case 4:
        return const Text('마이 페이지 내용');
      default:
        return const Text('알 수 없는 페이지');
    }
  }
}