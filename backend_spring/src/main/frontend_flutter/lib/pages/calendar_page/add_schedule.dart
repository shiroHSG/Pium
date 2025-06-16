import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/calendar/schedule.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

import '../../models/calendar/calendar_api.dart';
import '../../screens/calendar/add_schedule_ui.dart';
import '../../screens/calendar/calendar_page_ui.dart';

class AddSchedulePopup extends StatefulWidget {
  final DateTime initialDate;
  final Schedule? existingSchedule;

  const AddSchedulePopup({Key? key, required this.initialDate,this.existingSchedule}) : super(key: key);

  @override
  State<AddSchedulePopup> createState() => _AddSchedulePopupState();
}

class _AddSchedulePopupState extends State<AddSchedulePopup> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  Color? _selectedColor = AppTheme.primaryPurple;

  @override
  void initState() {
    super.initState();

    final existing = widget.existingSchedule;

    _titleController.text = existing?.title ?? '';
    _memoController.text = existing?.content ?? '';
    _dateController.text = DateFormat('yyyy년 MM월 dd일')
        .format(existing?.startTime ?? widget.initialDate);

    _timeController.text = existing != null
        ? formatToAmPm(existing.startTime)
        : '';

    _selectedColor = existing != null
        ? Color(int.parse('FF${existing.colorTag.replaceAll('#', '')}', radix: 16))
        : AppTheme.primaryPurple;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _saveSchedule() async {
    if (_titleController.text.isEmpty || _dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목, 날짜, 시간은 필수 입력 항목입니다.')),
      );
      return;
    }

    try {
      final date = DateFormat('yyyy년 MM월 dd일').parse(_dateController.text);

      // 오전/오후 + 시, 분 파싱
      final timeText = _timeController.text.trim();
      final amPmMatch = RegExp(r'^(오전|오후)').firstMatch(timeText);
      final timeMatch = RegExp(r'(\d+)시\s*(\d+)?분?').firstMatch(timeText);

      if (amPmMatch == null || timeMatch == null) {
        throw FormatException('시간 형식이 올바르지 않습니다.');
      }

      final amPm = amPmMatch.group(0); // 오전 or 오후
      int hour = int.parse(timeMatch.group(1)!);
      final minute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;

      // 오전/오후 처리
      if (amPm == '오후' && hour != 12) hour += 12;
      if (amPm == '오전' && hour == 12) hour = 0;

      final startTime = DateTime(date.year, date.month, date.day, hour, minute);
      final endTime = startTime.add(const Duration(hours: 1));

      final Schedule newSchedule = Schedule(
        id: widget.existingSchedule?.id,
        title: _titleController.text,
        content: _memoController.text,
        startTime: startTime,
        endTime: endTime,
        colorTag: '#${(_selectedColor ?? AppTheme.primaryPurple).value.toRadixString(16).padLeft(8, '0').substring(2)}',
      );

      if (widget.existingSchedule != null) {
        await CalendarApi.updateSchedule(newSchedule);
        Navigator.of(context).pop(newSchedule);
      } else {
        final saved = await CalendarApi.postSchedule(newSchedule);
        Navigator.of(context).pop(saved);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정 저장 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildScheduleDialog(
      context,
      _titleController,
      _dateController,
      _timeController,
      _memoController,
      _selectedColor,
      _onColorSelected,
      _saveSchedule,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy년 MM월 dd일').parse(_dateController.text),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryPurple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy년 MM월 dd일').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryPurple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }
}