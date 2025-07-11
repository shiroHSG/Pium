import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/models/calendar/schedule.dart';
import '../../models/calendar/calendar_api.dart';
import '../../pages/calendar_page/add_schedule.dart';

String formatToAmPm(DateTime dateTime) {
  final hour = dateTime.hour;
  final minute = dateTime.minute;
  final isAm = hour < 12;
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  final amPm = isAm ? '오전' : '오후';
  return '$amPm $displayHour시 ${minute.toString().padLeft(2, '0')}분';
}

class CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
  }) : super(key: key);

  String _getMonthYear(DateTime dateTime) {
    return DateFormat('yyyy년 MMMM', 'ko_KR').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left),
            onPressed: onPreviousMonth,
            color: AppTheme.textPurple,
          ),
          Text(
            _getMonthYear(focusedDay),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPurple),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right),
            onPressed: onNextMonth,
            color: AppTheme.textPurple,
          ),
        ],
      ),
    );
  }
}

class WeekdayLabels extends StatelessWidget {
  const WeekdayLabels({Key? key}) : super(key: key);

  Widget _buildWeekdayLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class CalendarDaysGrid extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Map<DateTime, List<Schedule>> schedules;

  const CalendarDaysGrid({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.schedules,
  }) : super(key: key);

  int _getDaysInMonth(DateTime date) => DateUtils.getDaysInMonth(date.year, date.month);
  DateTime _getFirstDayOfMonth(DateTime date) => DateTime(date.year, date.month, 1);
  int _getFirstDayOfWeekOfMonth(DateTime date) => _getFirstDayOfMonth(date).weekday % 7;
  List<Schedule> _getSchedulesForDay(DateTime day) => schedules[DateTime(day.year, day.month, day.day)] ?? [];

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final int firstDayOfWeek = DateTime.sunday;
    final int daysInMonth = _getDaysInMonth(focusedDay);
    final int firstWeekdayOfMonth = _getFirstDayOfWeekOfMonth(focusedDay);
    final List<int> daysList = List.generate(daysInMonth, (i) => i + 1);
    final int leadingEmptyDays = (firstWeekdayOfMonth - firstDayOfWeek + 7) % 7;
    final int trailingEmptyDays = (7 - ((leadingEmptyDays + daysInMonth) % 7)) % 7;

    final List<int?> calendarItems = [
      ...List.generate(leadingEmptyDays, (_) => null),
      ...daysList,
      ...List.generate(trailingEmptyDays, (_) => null),
    ];

    return Expanded(
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
          final currentDate = day != null ? DateTime(focusedDay.year, focusedDay.month, day) : null;
          final isSelected = isSameDay(selectedDay, currentDate);
          final isToday = isSameDay(DateTime.now(), currentDate);
          final isSameMonth = currentDate != null && currentDate.month == focusedDay.month;
          final schedulesForDay = currentDate != null ? _getSchedulesForDay(currentDate) : [];

          return GestureDetector(
            onTap: currentDate != null ? () => onDaySelected(currentDate, focusedDay) : null,
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
    );
  }
}

class SelectedDaySchedules extends StatelessWidget {
  final DateTime? selectedDay;
  final Map<DateTime, List<Schedule>> schedules;
  final Function(Schedule) onScheduleAdded;
  final Function(Schedule) onScheduleDeleted;
  final Function(Schedule) onScheduleEdited;

  const SelectedDaySchedules({
    Key? key,
    required this.selectedDay,
    required this.schedules,
    required this.onScheduleAdded,
    required this.onScheduleDeleted,
    required this.onScheduleEdited,
  }) : super(key: key);

  List<Schedule> _getSchedulesForDay(DateTime day) {
    return schedules[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null) return const SizedBox.shrink();
    final schedulesForSelectedDay = _getSchedulesForDay(selectedDay!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Container(
        height: 230,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 15.0),
        decoration: BoxDecoration(
          color: AppTheme.lightPink,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${DateFormat('d일').format(selectedDay!)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPurple,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 25),
                    color: AppTheme.textPurple,
                    onPressed: () async {
                      final newSchedule = await showDialog<Schedule>(
                        context: context,
                        builder: (_) => AddSchedulePopup(initialDate: selectedDay!),
                      );
                      if (newSchedule != null) {
                        onScheduleAdded(newSchedule);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('일정이 추가되었습니다.')),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: schedulesForSelectedDay.isEmpty
                    ? Center(
                  child: Text(
                    '선택된 날짜에 일정이 없습니다.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
                    : ListView.builder(
                  itemCount: schedulesForSelectedDay.length,
                  itemBuilder: (context, index) {
                    final schedule = schedulesForSelectedDay[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                              '${schedule.title} - ${formatToAmPm(schedule.startTime)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textPurple,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 10, minHeight: 30),
                                onPressed: () async {
                                  final editedSchedule = await showDialog<Schedule>(
                                    context: context,
                                    builder: (_) => AddSchedulePopup(
                                      initialDate: selectedDay!,
                                      existingSchedule: schedule,
                                    ),
                                  );
                                  if (editedSchedule != null) {
                                    onScheduleEdited(editedSchedule);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 10, minHeight: 30),
                                onPressed: () async {
                                  if (schedule.id == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('삭제할 수 없는 일정입니다 (id가 없음)')),
                                    );
                                    return;
                                  }
                                  try {
                                    await CalendarApi.deleteSchedule(schedule.id!);
                                    onScheduleDeleted(schedule);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('일정이 삭제되었습니다.')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('삭제 실패: $e')),
                                    );
                                  }
                                },
                              ),
                            ],
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
      ),
    );
  }
}

class AddScheduleButton extends StatelessWidget {
  final DateTime? selectedDay;
  final Function(Schedule) onScheduleAdded;

  const AddScheduleButton({
    Key? key,
    required this.selectedDay,
    required this.onScheduleAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0, bottom: 20.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: ElevatedButton(
          onPressed: () async {
            final initialDateForPopup = selectedDay ?? DateTime.now();
            final newSchedule = await showDialog<Schedule>(
              context: context,
              builder: (BuildContext context) {
                return AddSchedulePopup(initialDate: initialDateForPopup);
              },
            );
            if (newSchedule != null) {
              onScheduleAdded(newSchedule);
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
    );
  }
}
