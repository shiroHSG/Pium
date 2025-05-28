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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Schedule> _schedules = [];
  BabyProfile _babyProfile = BabyProfile(
    name: '아이',
    dob: 'YY-MM-DD',
    height: '00',
    weight: '00',
    development: 'OO이는 성장 중입니다.',
  );
  ImageProvider? _babyImage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadBabyProfile();
  }

  Future<void> _loadBabyProfile() async {
    // 실제로는 API 호출 또는 로컬 저장소에서 아이 정보를 가져와야 합니다.
    // 임시로 초기값을 설정합니다.
    setState(() {
      _babyImage = const AssetImage('assets/default_baby.png');
    });
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
                TextField(
                  controller: _developmentController,
                  decoration: const InputDecoration(labelText: '성장 발달 내용'),
                  maxLines: 2,
                ),
                // 이미지 선택 기능은 추가적인 구현이 필요합니다.
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
      floatingActionButton: _selectedIndex == 0
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
                padding: const EdgeInsets.only(
                    left: 0.0, top: 0.0, right: 0.0, bottom: 40.0),
                child: GestureDetector(
                  onTap: _showEditBabyProfileDialog,
                  child: Container(
                    width: screenWidth,
                    height: 250,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 30.0),
                    decoration: BoxDecoration(
                      color: AppTheme.lightPink,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(15)),
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
                                image: _babyImage != null
                                    ? DecorationImage(
                                  image: _babyImage!,
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: _babyImage == null
                                  ? const Center(
                                child: Text(
                                  '아이\n사진',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _babyProfile.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: AppTheme.textPurple,
                                  ),
                                ),
                                Text(
                                  '${_babyProfile.dob} / ${_babyProfile.height ?? '??'} cm / ${_babyProfile.weight ?? '??'} kg',
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
                            padding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              _babyProfile.development ?? '성장 발달 내용이 없습니다.',
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: GestureDetector(
                  onTap: _navigateToCalendarPage,
                  child: Container(
                    padding:
                    const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                    decoration: BoxDecoration(
                      color: AppTheme.lightPink,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios,
                            color: Colors.grey[600], size: 20),
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
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.grey[600], size: 20),
                      ],
                    ),
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
                    padding:
                    EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    child: Text(
                      '인기 게시글',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        child: Icon(Icons.arrow_forward_ios,
                            color: AppTheme.textPurple),
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

class BabyProfile {
  String name;
  String dob;
  String? gender;
  String? height;      // cm
  String? weight;      // kg
  String? allergies;
  String? development; // 발달 단계 등 추가 필드

  BabyProfile({
    required this.name,
    required this.dob,
    this.gender,
    this.height,
    this.weight,
    this.allergies,
    this.development,
  });

  BabyProfile copyWith({
    String? name,
    String? dob,
    String? gender,
    String? height,
    String? weight,
    String? allergies,
    String? development,
  }) {
    return BabyProfile(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      allergies: allergies ?? this.allergies,
      development: development ?? this.development,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BabyProfile &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              dob == other.dob &&
              gender == other.gender &&
              height == other.height &&
              weight == other.weight &&
              allergies == other.allergies &&
              development == other.development;

  @override
  int get hashCode =>
      name.hashCode ^
      dob.hashCode ^
      gender.hashCode ^
      height.hashCode ^
      weight.hashCode ^
      allergies.hashCode ^
      development.hashCode;
}