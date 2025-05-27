import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/baby_record/baby_record_page.dart';
import 'package:frontend_flutter/pages/search/people_search_page.dart';
import 'package:frontend_flutter/pages/my_page/my_page.dart';
import 'package:frontend_flutter/widgets/custom_app_bar.dart';
import 'package:frontend_flutter/widgets/custom_bottom_bar.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/widgets/custom_drawer.dart';
import 'package:frontend_flutter/pages/sharing_page/sharing_page.dart';
import 'package:frontend_flutter/models/schedule.dart';
import 'package:frontend_flutter/pages/calendar_page/add_schedule.dart'; // AddSchedulePopup 임포트

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Schedule> _schedules = []; // 일정을 저장할 리스트

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    // 초기 더미 일정 추가 (선택 사항)
    _schedules.add(
      Schedule(
        title: '태하 예방접종',
        date: DateTime.now(),
        time: '14:00',
        color: AppTheme.primaryPurple,
      ),
    );
    _schedules.add(
      Schedule(
        title: '태하아빠 회의',
        date: DateTime.now(),
        time: '15:00',
        color: Colors.orange,
      ),
    );
    _schedules.add(
      Schedule(
        title: '가족 외식',
        date: DateTime.now(),
        time: '20:00',
        color: Colors.lightGreen,
      ),
    );
  }

  void _checkLoginStatus() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
        Navigator.pop(context);
      }
    });
  }

  void _onLoginStatusChanged(bool status) {
    setState(() {
      _isLoggedIn = status;
    });
  }

  Future<void> _showAddSchedulePopup() async {
    final newSchedule = await showDialog<Schedule>(
      context: context,
      builder: (BuildContext context) {
        return AddSchedulePopup(initialDate: DateTime.now());
      },
    );

    if (newSchedule != null) {
      setState(() {
        _schedules.add(newSchedule);
        // 날짜와 시간순으로 정렬
        _schedules.sort((a, b) {
          int dateComparison = a.date.compareTo(b.date);
          if (dateComparison != 0) {
            return dateComparison;
          }
          return a.time.compareTo(b.time);
        });
      });
    }
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
      floatingActionButton: _selectedIndex == 0 // 홈 페이지일 때만 버튼 표시
          ? FloatingActionButton(
        onPressed: _showAddSchedulePopup,
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Widget _getPageContent(int index) {
    final double screenWidth = MediaQuery.of(context).size.width;

    switch (index) {
      case 0:
      // 오늘 날짜의 일정 필터링
        final today = DateTime.now();
        final todaySchedules = _schedules
            .where((schedule) =>
        schedule.date.year == today.year &&
            schedule.date.month == today.month &&
            schedule.date.day == today.day)
            .toList();

        return SingleChildScrollView(
          child: Column(
            children: [
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
                              '${today.day}일',
                              style: TextStyle(
                                color: AppTheme.textPurple,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (todaySchedules.isEmpty)
                              const Text(
                                '오늘 일정이 없습니다.',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ...todaySchedules.map((schedule) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: schedule.color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${schedule.title} - ${schedule.time}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            )),
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
      case 1:
        return const BabyRecordPage();
      case 2:
        return const Center(child: Text('채팅 페이지 내용'));
      case 3:
        return const PeopleSearchPage();
      case 4:
        return const MyPage();
      case 5:
        return const SharingPage();
      default:
        return const Center(child: Text('알 수 없는 페이지'));
    }
  }
}