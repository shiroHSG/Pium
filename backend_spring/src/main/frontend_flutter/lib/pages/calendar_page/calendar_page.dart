import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/pages/calendar_page/add_schedule.dart';
import 'package:frontend_flutter/models/schedule.dart';

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
      print('Selected day: $_selectedDay');
    }
  }

  String _getMonthYear(DateTime dateTime) {
    return DateFormat('yyyy년 MMMM', 'ko_KR').format(dateTime);
  }

  int _getDaysInMonth(DateTime date) {
    return DateUtils.getDaysInMonth(date.year, date.month);
  }

  DateTime _getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  int _getFirstDayOfWeekOfMonth(DateTime date) {
    return _getFirstDayOfMonth(date).weekday % 7;
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
      _selectedDay = null;
      print('PREV month pressed. New _focusedDay: $_focusedDay');
      print('Month Text: ${DateFormat('yyyy년 MMMM', 'ko_KR').format(_focusedDay)}');
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
      _selectedDay = null;
      print('NEXT month pressed. New _focusedDay: $_focusedDay');
      print('Month Text: ${DateFormat('yyyy년 MMMM', 'ko_KR').format(_focusedDay)}');
    });
  }

  List<Schedule> _getSchedulesForDay(DateTime day) {
    return _schedules[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final int firstDayOfWeek = DateTime.sunday;
    final int daysInMonth = _getDaysInMonth(_focusedDay);
    final int firstWeekdayOfMonth = _getFirstDayOfWeekOfMonth(_focusedDay);

    final List<int> daysList = List.generate(daysInMonth, (i) => i + 1);
    final int leadingEmptyDays = (firstWeekdayOfMonth - firstDayOfWeek + 7) % 7;
    final int trailingEmptyDays = (7 - ((leadingEmptyDays + daysInMonth) % 7)) % 7;

    final List<int?> calendarItems = [
      ...List.generate(leadingEmptyDays, (_) => null),
      ...daysList,
      ...List.generate(trailingEmptyDays, (_) => null),
    ];

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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: _goToPreviousMonth,
                  color: AppTheme.textPurple,
                ),
                Text(
                  _getMonthYear(_focusedDay),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPurple),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: _goToNextMonth,
                  color: AppTheme.textPurple,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeekdayLabel('일'),
                _buildWeekdayLabel('월'),
                _buildWeekdayLabel('화'),
                _buildWeekdayLabel('수'),
                _buildWeekdayLabel('목'),
                _buildWeekdayLabel('금'),
                _buildWeekdayLabel('토'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: calendarItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 3,
                mainAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                final day = calendarItems.elementAt(index);
                final currentDate = day != null
                    ? DateTime(_focusedDay.year, _focusedDay.month, day)
                    : null;
                final isSelected = isSameDay(_selectedDay, currentDate);
                final isToday = isSameDay(DateTime.now(), currentDate);
                final isSameMonth = currentDate != null && currentDate.month == _focusedDay.month;
                final schedulesForDay = currentDate != null ? _getSchedulesForDay(currentDate) : [];

                return GestureDetector(
                  onTap: currentDate != null ? () => _onDaySelected(currentDate, _focusedDay) : null,
                  child: Column(
                    children: [
                      Container(
                        width: isSelected ? 36 : 30,
                        height: isSelected ? 36 : 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppTheme.primaryPurple : null,
                        ),
                        child: Center(
                          child: Text(
                            day?.toString() ?? '',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isToday && isSameMonth
                                  ? Colors.redAccent
                                  : isSameMonth
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      if (schedulesForDay.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: schedulesForDay.take(3).map((schedule) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: schedule.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_selectedDay != null)
            Container(
              height: 180,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              decoration: BoxDecoration(
                color: AppTheme.lightPink,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat('d일').format(_selectedDay!)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _getSchedulesForDay(_selectedDay!).isEmpty
                        ? Center(
                      child: Text(
                        '선택된 날짜에 일정이 없습니다.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _getSchedulesForDay(_selectedDay!).length,
                      itemBuilder: (context, index) {
                        final schedule = _getSchedulesForDay(_selectedDay!)[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6, right: 8),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: schedule.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '- ${schedule.title} - ${schedule.time}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0,bottom: 20.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    // _selectedDay가 null일 경우를 대비하여 현재 날짜를 기본값으로 사용
                    final initialDateForPopup = _selectedDay ?? DateTime.now();

                    final newSchedule = await showDialog<Schedule>(
                      context: context,
                      builder: (BuildContext context) {
                        return AddSchedulePopup(initialDate: initialDateForPopup);
                      },
                    );

                    if (newSchedule != null) {
                      setState(() {
                        final dateKey = DateTime(newSchedule.date.year, newSchedule.date.month, newSchedule.date.day);
                        _schedules.update(
                          dateKey,
                              (existingSchedules) {
                            existingSchedules.add(newSchedule);
                            existingSchedules.sort((a, b) => DateFormat('HH:mm').parse(a.time).compareTo(DateFormat('HH:mm').parse(b.time)));
                            return existingSchedules;
                          },
                          ifAbsent: () => [newSchedule],
                        );
                        if (isSameDay(_selectedDay, dateKey)) {
                          _selectedDay = dateKey;
                        }
                      });
                      print('새 일정 추가됨: ${newSchedule.title} on ${newSchedule.date}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('일정 추가'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}