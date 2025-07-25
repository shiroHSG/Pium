import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:frontend_flutter/pages/baby_record/baby_record_page.dart';
import 'package:frontend_flutter/pages/my_page/my_page.dart';
import 'package:frontend_flutter/widgets/custom_app_bar.dart';
import 'package:frontend_flutter/widgets/custom_bottom_bar.dart';
import 'package:frontend_flutter/widgets/custom_drawer.dart';
import 'package:frontend_flutter/pages/sharing_page/sharing_page.dart';
import 'package:frontend_flutter/models/calendar/schedule.dart';
import 'package:frontend_flutter/pages/calendar_page/calendar_page.dart';
import 'package:frontend_flutter/pages/calendar_page/add_schedule.dart';
import 'package:frontend_flutter/pages/chat/chatting_page.dart';
import 'package:frontend_flutter/screens/home/home_page_ui.dart';
import 'package:frontend_flutter/pages/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/calendar/calendar_api.dart';
import '../../models/chat/chat_service.dart';
import '../../models/notification/notification.dart';
import '../../models/webSocket/connectWebSocket.dart';
import '../../models/child/child_api.dart';
import '../community/community_page.dart';
import '../my_page/baby_profile/babyProfile_page.dart';

class MyHomePage extends StatefulWidget {
  final int initialIndex;
  const MyHomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  int _currentPage = 0;
  int _unreadCount = 0;
  int _unreadAlarmCount = 0;
  String? _token;
  final PageController _pageController = PageController();

  List<BabyProfile> _children = [];
  List<Schedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _checkLoginStatus();
    _loadBabyProfile();
    _loadSchedules();
    _fetchUnreadCount();
    _fetchUnreadMessageCount();
    _connectWebSocket();

    onUnreadAlarmCountUpdate = (count) {
      setState(() {
        _unreadAlarmCount = count; // AppBar 전용
      });
    };
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
            (route) => false,
      );
    }
  }

  Future<void> _connectWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');
    final int? myId = prefs.getInt('memberId');

    if (token != null && myId != null) {
      _token = token;
      connectStomp(token, myId, _updateUnreadCount);
    } else {
      print('❌ WebSocket 연결 실패: token 또는 memberId 없음');
    }
  }

  void _updateUnreadCount(int count) {
    setState(() {
      _unreadCount = count;
    });
  }

  Future<void> _fetchUnreadMessageCount() async {
    final count = await getUnreadCount();
    setState(() {
      _unreadCount = count;
    });
  }

  Future<void> _fetchUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    print("fetchunreadCount : $token");
    if (token == null) return;

    _token = token;
    await fetchUnreadNotificationCount(token, (count) {
      setState(() {
        _unreadAlarmCount = count;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
        Navigator.pop(context);
      }
      if (index == 0) {
        _loadBabyProfile();
      }
    });
  }

  void _onLoginStatusChanged(bool status) {
    if (!status) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
            (route) => false,
      );
    }
  }

  void _BabyProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BabyProfilePage()),
    ).then((_) => _loadBabyProfile());
  }

  Future<void> _loadBabyProfile() async {
    final children = await ChildApi.fetchMyChildren();
    if (children.isNotEmpty) {
      setState(() {
        _children = children;
      });
    }
  }

  Future<void> _loadSchedules() async {
    try {
      final schedules = await CalendarApi.fetchSchedules();
      setState(() {
        _schedules = schedules..sort((a, b) => a.startTime.compareTo(b.startTime));
      });
    } catch (e) {
      print('일정 불러오기 실패: $e');
    }
  }

  Future<void> _navigateToCalendarPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarPage()),
    );
    await _loadSchedules();
  }

  Future<void> _showAddSchedulePopup() async {
    final newSchedule = await showDialog<Schedule>(
      context: context,
      builder: (context) => AddSchedulePopup(initialDate: DateTime.now()),
    );

    if (newSchedule != null) {
      setState(() {
        _schedules.add(newSchedule);
        _schedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
    }
  }

  Future<void> _showEditDialogForChild(BabyProfile child) async {
    final _nameController = TextEditingController(text: child.name);
    final _birthDateController = TextEditingController(text: child.birthDate.toIso8601String().split('T').first);
    final _heightController = TextEditingController(text: child.height?.toString() ?? '');
    final _weightController = TextEditingController(text: child.weight?.toString() ?? '');
    final _developmentController = TextEditingController(text: child.developmentStep ?? '');

    await showDialog(
      context: context,
      builder: (context) {
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
            TextButton(child: const Text('취소'), onPressed: () => Navigator.pop(context)),
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
                await ChildApi.updateMyChild(child);
                await _loadBabyProfile();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('아이 정보가 성공적으로 수정되었습니다')),
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todaySchedules = _schedules.where((s) =>
    s.startTime.year == today.year &&
        s.startTime.month == today.month &&
        s.startTime.day == today.day
    ).toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        unreadCount:  _unreadAlarmCount,
        onReloadNotificationCount: _fetchUnreadCount,
      ),
      endDrawer: CustomDrawer(
        onItemSelected: _onItemTapped,
        onLoginStatusChanged: _onLoginStatusChanged,
      ),
      body: _getPageContent(todaySchedules),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        unreadCount: _unreadCount,
      ),
    );
  }

  Widget _getPageContent(List<Schedule> todaySchedules) {
    switch (_selectedIndex) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 250,
                child: _children.isEmpty
                    ? BabyProfileHeader(
                  babyProfile: BabyProfile(
                    name: '등록된 아이 없음',
                    birthDate: DateTime.now(),
                    gender: null,
                  ),
                  babyImage: null,
                  onEditPressed: _BabyProfilePage,
                )
                    : PageView.builder(
                  controller: _pageController,
                  itemCount: _children.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final child = _children[index];
                    final ImageProvider<Object> image =
                    (child.profileImageUrl != null && child.profileImageUrl!.isNotEmpty)
                        ? NetworkImage('${child.profileImageUrl}')
                        : const AssetImage('assets/default_baby.png');
                    return BabyProfileHeader(
                      babyProfile: child,
                      babyImage: image,
                      onEditPressed: () => _showEditDialogForChild(child),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (_children.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_children.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? Colors.black : Colors.grey,
                      ),
                    );
                  }),
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
        return const CommunityPage();
      case 4:
        return const MyPage();
      case 5:
        return const SharingPage();
      default:
        return const Center(child: Text('알 수 없는 페이지'));
    }
  }
}
