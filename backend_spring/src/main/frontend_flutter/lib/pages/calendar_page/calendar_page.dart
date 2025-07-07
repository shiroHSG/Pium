import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/calendar/schedule.dart';
import 'package:frontend_flutter/models/calendar/calendar_api.dart';
import 'package:frontend_flutter/screens/calendar/calendar_page_ui.dart';

import '../../widgets/notification_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late PageController _pageController;
  late int _currentMonthIndex;

  Map<DateTime, List<Schedule>> _schedules = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _currentMonthIndex = 0;
    _pageController = PageController(initialPage: _currentMonthIndex);
    _loadSchedules(); // 일정 불러오기
  }

  Future<void> _loadSchedules() async {
    try {
      final fetched = await CalendarApi.fetchSchedules();
      final Map<DateTime, List<Schedule>> grouped = {};

      for (var s in fetched) {
        final key = DateTime(s.date.year, s.date.month, s.date.day);
        grouped.putIfAbsent(key, () => []).add(s);
      }

      grouped.forEach((key, list) {
        list.sort((a, b) => a.startTime.compareTo(b.startTime));
      });

      setState(() {
        _schedules = grouped;
      });
    } catch (e) {
      print('Mate 일정 포함 일정 불러오기 실패: $e');
    }
  }


  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      });
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
      _selectedDay = null;
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
      _selectedDay = null;
    });
  }

  // 일정 추가 핸들러 함수
  void _handleScheduleAdded(Schedule newSchedule) {
    final dateKey = DateTime(
      newSchedule.date.year,
      newSchedule.date.month,
      newSchedule.date.day,
    );

    final updatedSchedules = Map<DateTime, List<Schedule>>.from(_schedules);
    updatedSchedules.update(
      dateKey,
          (existing) {
        existing.add(newSchedule);
        existing.sort((a, b) => a.startTime.compareTo(b.startTime));
        return existing;
      },
      ifAbsent: () => [newSchedule],
    );

    setState(() {
      _schedules = updatedSchedules;
      _selectedDay = dateKey;
      _focusedDay = dateKey;
    });
  }

  // 일정 삭제 핸들러 함수
  void _handleScheduleDeleted(Schedule deletedSchedule) {
    final dateKey = DateTime(
      deletedSchedule.date.year,
      deletedSchedule.date.month,
      deletedSchedule.date.day,
    );

    final updatedSchedules = Map<DateTime, List<Schedule>>.from(_schedules);
    updatedSchedules[dateKey]?.removeWhere((s) => s.id == deletedSchedule.id);

    setState(() {
      _schedules = updatedSchedules;
    });
  }

  void _handleScheduleEdited(Schedule updatedSchedule) {
    final dateKey = DateTime(
      updatedSchedule.date.year,
      updatedSchedule.date.month,
      updatedSchedule.date.day,
    );

    final updatedSchedules = Map<DateTime, List<Schedule>>.from(_schedules);

    if (updatedSchedules.containsKey(dateKey)) {
      final index = updatedSchedules[dateKey]!
          .indexWhere((s) => s.id == updatedSchedule.id);
      if (index != -1) {
        updatedSchedules[dateKey]![index] = updatedSchedule;
      }
    }

    setState(() {
      _schedules = updatedSchedules;
    });
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        title: const Text('캘린더'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CalendarHeader(
            focusedDay: _focusedDay,
            onPreviousMonth: _goToPreviousMonth,
            onNextMonth: _goToNextMonth,
          ),
          const WeekdayLabels(),
          CalendarDaysGrid(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: _onDaySelected,
            schedules: _schedules,
          ),
          SelectedDaySchedules(
            selectedDay: _selectedDay,
            schedules: _schedules,
            onScheduleDeleted: _handleScheduleDeleted,
            onScheduleAdded: _handleScheduleAdded,
            onScheduleEdited: _handleScheduleEdited,
          ),

        ],
      ),
    );
  }
}