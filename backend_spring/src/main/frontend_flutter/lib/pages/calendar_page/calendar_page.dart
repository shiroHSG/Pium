import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/calendar/schedule.dart';
import 'package:frontend_flutter/models/calendar/calendar_api.dart';
import 'package:frontend_flutter/screens/calendar/calendar_page_ui.dart';

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

      setState(() {
        _schedules = grouped;
      });
    } catch (e) {
      print('일정 불러오기 실패: \$e');
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

  void _handleScheduleAdded(Schedule newSchedule) async {
    try {
      await CalendarApi.postSchedule(newSchedule);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일정 저장 실패')),
      );
      return;
    }

    final dateKey = DateTime(newSchedule.date.year, newSchedule.date.month, newSchedule.date.day);
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

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        title: const Text('일정'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
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
          ),
          AddScheduleButton(
            selectedDay: _selectedDay,
            onScheduleAdded: _handleScheduleAdded,
          ),
        ],
      ),
    );
  }
}
