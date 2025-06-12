import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:frontend_flutter/pages/baby_record/baby_record_page.dart';
import 'package:frontend_flutter/pages/search/people_search_page.dart';
import 'package:frontend_flutter/pages/my_page/my_page.dart';
import 'package:frontend_flutter/widgets/custom_app_bar.dart';
import 'package:frontend_flutter/widgets/custom_bottom_bar.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/widgets/custom_drawer.dart';
import 'package:frontend_flutter/pages/sharing_page/sharing_page.dart';
import 'package:frontend_flutter/models/schedule.dart';
import 'package:frontend_flutter/pages/calendar_page/add_schedule.dart';
import 'package:frontend_flutter/pages/calendar_page/calendar_page.dart';
import 'package:frontend_flutter/pages/chatting/chatting_page.dart';
import 'package:frontend_flutter/screens/home/home_page_ui.dart';
import 'package:frontend_flutter/pages/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Schedule> _schedules = [];
  BabyProfile _babyProfile = BabyProfile(
    name: '아이',
    dob: 'YY-MM-DD',
    height: '00',
    weight: '00',
    development: '00이는 생후 4개월이에요. 팔을 뻗어서 물체를 잡으려고 해요.',
  );
  ImageProvider? _babyImage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // 로그인 상태 체크
    _loadBabyProfile();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      print('토큰 없음: 로그인 페이지로 리다이렉트');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _loadBabyProfile() async {
    setState(() {
      _babyImage = const AssetImage('assets/default_baby.png');
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
      if (!status) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Login()),
              (Route<dynamic> route) => false,
        );
      }
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

  void _navigateToCalendarPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarPage()),
    );
  }

  Future<void> _showEditBabyProfileDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final _nameController = TextEditingController(text: _babyProfile.name);
        final _birthDateController = TextEditingController(text: _babyProfile.dob);
        final _heightController = TextEditingController(text: _babyProfile.height ?? '');
        final _weightController = TextEditingController(text: _babyProfile.weight ?? '');
        final _developmentController =
        TextEditingController(text: _babyProfile.development ?? '');

        return AlertDialog(
          title: const Text('아이 정보 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '이름'),
                ),
                TextField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(labelText: '생년월일 (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: '키 (cm)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: '몸무게 (kg)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('저장'),
              onPressed: () {
                setState(() {
                  _babyProfile = BabyProfile(
                    name: _nameController.text,
                    dob: _birthDateController.text,
                    height: _heightController.text.isEmpty ? null : _heightController.text,
                    weight: _weightController.text.isEmpty ? null : _weightController.text,
                    development: _developmentController.text.isEmpty ? null : _developmentController.text,
                  );
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  // 화면의 전체 구조
      key: _scaffoldKey,
      appBar: CustomAppBar(
        onMenuPressed: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      endDrawer: CustomDrawer(
        onItemSelected: _onItemTapped,
        onLoginStatusChanged: _onLoginStatusChanged,
      ),
      body: _getPageContent(_selectedIndex),  // 선택된 탭(인덱스)에 따라 화면을 바꿔줌
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: null,
    );
  }

  Widget _getPageContent(int index) {
    switch (index) {
      case 0:
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
              BabyProfileHeader(
                babyProfile: _babyProfile,
                babyImage: _babyImage,
                onEditPressed: _showEditBabyProfileDialog,
              ),
              TodayScheduleCard(
                todaySchedules: todaySchedules,
                onCalendarTap: _navigateToCalendarPage,
              ),
              const PopularPostsSection(),
            ],
          ),
        );
      case 1:
        return const BabyRecordPage();
      case 2:
        return ChattingPage();
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