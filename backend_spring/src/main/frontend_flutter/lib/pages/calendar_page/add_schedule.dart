import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/models/calendar/schedule.dart';
import 'package:frontend_flutter/screens/calendar/add_calendar_ui.dart';

class AddSchedulePopup extends StatefulWidget {
  final DateTime initialDate;

  const AddSchedulePopup({Key? key, required this.initialDate}) : super(key: key);

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
    _dateController.text = DateFormat('yyyy-MM-dd').format(widget.initialDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_dateController.text),
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
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _dateController.text = formattedDate;
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

  void _saveSchedule() {
    if (_titleController.text.isEmpty || _dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목, 날짜, 시간은 필수 입력 항목입니다.')),
      );
      return;
    }

    // 날짜 + 시간 조합
    final date = DateFormat('yyyy-MM-dd').parse(_dateController.text);
    final timeParts = _timeController.text.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final startTime = DateTime(date.year, date.month, date.day, hour, minute);
    final endTime = startTime.add(const Duration(hours: 1));

    final newSchedule = Schedule(
      id: null,
      title: _titleController.text,
      content: _memoController.text.isEmpty ? '' : _memoController.text,
      startTime: startTime,
      endTime: endTime,
      colorTag: '#${(_selectedColor ?? AppTheme.primaryPurple).value.toRadixString(16).padLeft(8, '0').substring(2)}',
    );

    Navigator.of(context).pop(newSchedule);
  }


  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppTheme.lightPink,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddScheduleHeader(onClose: () => Navigator.of(context).pop()),
            ScheduleInputField(hint: '일정 제목', controller: _titleController),
            const SizedBox(height: 15),
            ScheduleInputField(
              hint: '날짜',
              controller: _dateController,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 15),
            ScheduleInputField(
              hint: '시간',
              controller: _timeController,
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 15),
            ScheduleInputField(
              hint: '메모(선택)',
              controller: _memoController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ColorPalette(
              initialColor: _selectedColor,
              onColorSelected: _onColorSelected,
            ),
            const SizedBox(height: 30),
            AddScheduleButton(onSave: _saveSchedule),
          ],
        ),
      ),
    );
  }
}