// lib/pages/calendar_page/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/pages/calendar_page/add_schedule.dart';
import 'package:frontend_flutter/models/schedule.dart';
import 'package:frontend_flutter/screens/calendar/calendar_page_ui.dart';
import 'package:intl/intl.dart';

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

    _schedules[DateTime(2025, 5, 19)] = [
      Schedule(title: '병원 예약진료', date: DateTime(2025, 5, 19), time: '14:00', color: Colors.blue),
      Schedule(title: '회의', date: DateTime(2025, 5, 19), time: '15:00', color: Colors.green),
      Schedule(title: '가족 외식', date: DateTime(2025, 5, 19), time: '20:00', color: Colors.red),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  List<Schedule> _getSchedulesForDay(DateTime day) {
    return _schedules[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _handleScheduleAdded(Map<DateTime, List<Schedule>> updatedSchedules) {
    setState(() {
      _schedules = updatedSchedules;
      if (_selectedDay != null && updatedSchedules.containsKey(_selectedDay)) {
        // Keep the selected day if it has schedules
      } else if (updatedSchedules.isNotEmpty) {
        _selectedDay = updatedSchedules.keys.lastWhere((key) => true, orElse: () => DateTime.now());
        _focusedDay = _selectedDay!;
      }
    });
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
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
            schedules: _schedules,
            onScheduleAdded: _handleScheduleAdded,
          ),
        ],
      ),
    );
  }
}