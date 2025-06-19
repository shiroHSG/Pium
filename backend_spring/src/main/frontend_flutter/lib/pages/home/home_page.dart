import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:frontend_flutter/pages/baby_record/baby_record_page.dart';
import 'package:frontend_flutter/pages/search/people_search_page.dart';
import 'package:frontend_flutter/pages/my_page/my_page.dart';
import 'package:frontend_flutter/widgets/custom_app_bar.dart';
import 'package:frontend_flutter/widgets/custom_bottom_bar.dart';
import 'package:frontend_flutter/widgets/custom_drawer.dart';
import 'package:frontend_flutter/pages/sharing_page/sharing_page.dart';
import 'package:frontend_flutter/models/calendar/schedule.dart';
import 'package:frontend_flutter/pages/calendar_page/add_schedule.dart';
import 'package:frontend_flutter/pages/calendar_page/calendar_page.dart';
import 'package:frontend_flutter/pages/chatting/chatting_page.dart';
import 'package:frontend_flutter/screens/home/home_page_ui.dart';
import 'package:frontend_flutter/pages/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/child/child_api.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BabyProfile> _children = [];
  int _selectedIndex = 0;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Schedule> _schedules = [];
  BabyProfile _babyProfile = BabyProfile(
    name: '아이',
    birthDate: DateTime(2024, 1, 1),
    gender: Gender.MALE,
    height: 0,
    weight: 0,
    developmentStep: '00이는 생후 4개월이에요. 팔을 뻗어서 물체를 잡으려고 해요.',
  );

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadBabyProfile();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _loadBabyProfile() async {
    final children = await ChildApi.fetchMyChildren();

    for (var child in children) {
      print('[DEBUG] 이름: ${child.name}, 생일: ${child.birthDate}, 성별: ${child.gender}, 이미지: ${child.profileImageUrl}');
    }

    if (children.isNotEmpty) {
      final firstChild = children.first;

      ImageProvider image;

      if (firstChild.profileImageUrl != null && firstChild.profileImageUrl!.isNotEmpty) {
        image = NetworkImage('http://10.0.2.2:8080${firstChild.profileImageUrl}');
      } else {
        final assetImage = const AssetImage('assets/default_baby.png');
        await precacheImage(assetImage, context);
        image = assetImage;
      }

      setState(() {
        _children = children;
        _babyProfile = firstChild;
      });
    } else {
      print('[DEBUG] 서버로부터 아이 정보 없음');
    }
  }


  void _onItemTapped(int index) {
    final isSameTab = _selectedIndex == index;

    setState(() {
      _selectedIndex = index;
      if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
        Navigator.pop(context);
      }
    });
    // ✅ 이미 홈(0번)인 상태에서 다시 클릭한 경우에도 새로고침
    if (index == 0) {
      _loadBabyProfile();
    }
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
          return a.startTime.compareTo(b.startTime);
        });
      });
    }
  }

  void _navigateToCalendarPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarPage()),
    );
    _loadBabyProfile();
  }

  Future<void> _showEditBabyProfileDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final _nameController = TextEditingController(text: _babyProfile.name);
        final _birthDateController = TextEditingController(text: _babyProfile.birthDate.toIso8601String().split('T').first);
        final _heightController = TextEditingController(text: _babyProfile.height?.toString() ?? '');
        final _weightController = TextEditingController(text: _babyProfile.weight?.toString() ?? '');
        final _developmentController = TextEditingController(text: _babyProfile.developmentStep ?? '');

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
                    birthDate: DateTime.tryParse(_birthDateController.text) ?? DateTime(2024, 1, 1),
                    gender: _babyProfile.gender,
                    height: double.tryParse(_heightController.text),
                    weight: double.tryParse(_weightController.text),
                    developmentStep: _developmentController.text.isEmpty ? null : _developmentController.text,
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

  Future<void> _showEditDialogForChild(BabyProfile child) async {
    final _nameController = TextEditingController(text: child.name);
    final _birthDateController = TextEditingController(text: child.birthDate.toIso8601String().split('T').first);
    final _heightController = TextEditingController(text: child.height?.toString() ?? '');
    final _weightController = TextEditingController(text: child.weight?.toString() ?? '');
    final _developmentController = TextEditingController(text: child.developmentStep ?? '');

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('아이 정보 수정'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: '이름')),
                TextField(controller: _birthDateController, decoration: const InputDecoration(labelText: '생년월일')),
                TextField(controller: _heightController, decoration: const InputDecoration(labelText: '키(cm)')),
                TextField(controller: _weightController, decoration: const InputDecoration(labelText: '몸무게(kg)')),
                TextField(controller: _developmentController, decoration: const InputDecoration(labelText: '성장단계')),
              ],
            ),
          ),
          actions: [
            TextButton(child: const Text('취소'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('저장'),
              onPressed: () async {
                setState(() {
                  child.name = _nameController.text;
                  child.birthDate = DateTime.tryParse(_birthDateController.text) ?? child.birthDate;
                  child.height = double.tryParse(_heightController.text);
                  child.weight = double.tryParse(_weightController.text);
                  child.developmentStep = _developmentController.text;
                });
                try {
                  await ChildApi.updateMyChild(child);
                  await _loadBabyProfile();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('아이 정보가 성공적으로 수정되었습니다')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('아이 정보 수정에 실패했습니다')),
                  );
                }
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      endDrawer: CustomDrawer(
        onItemSelected: _onItemTapped,
        onLoginStatusChanged: _onLoginStatusChanged,
      ),
      body: _getPageContent(_selectedIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
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

        return Column(
          children: [
            // 1️⃣ 아이 슬라이더 + 인디케이터 (상단 1/3)
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _children.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final child = _children[index];

                        final ImageProvider image = (child.profileImageUrl != null && child.profileImageUrl!.isNotEmpty)
                            ? NetworkImage('http://10.0.2.2:8080${child.profileImageUrl}')
                            : const AssetImage('assets/default_baby.png');

                        return BabyProfileHeader(
                          babyProfile: child,
                          babyImage: image,
                          onEditPressed: () => _showEditDialogForChild(child),
                        );
                      },
                    )
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_children.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.black
                              : Colors.grey[400],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // 2️⃣ 일정 등록 및 이동 버튼 (중단 1/3)
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _showAddSchedulePopup,
                    child: const Text('일정 추가'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _navigateToCalendarPage,
                    child: const Text('캘린더로 이동'),
                  ),
                ],
              ),
            ),

            // 3️⃣ 정책/커뮤니티/나눔 영역 (하단 1/3)
            Expanded(
              flex: 1,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('정책 및 커뮤니티 영역 (추후 구현 예정)', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        );
    // 나머지 탭
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
