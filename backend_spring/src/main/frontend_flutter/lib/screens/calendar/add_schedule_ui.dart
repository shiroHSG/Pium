import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

import '../../models/calendar/schedule.dart';

Future<void> onDateTap(BuildContext context, TextEditingController dateController) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    locale: const Locale('ko', 'KR'),
  );
  if (picked != null) {
    dateController.text = '${picked.year}년 ${picked.month}월 ${picked.day}일';
  }
}

Future<void> showCustomTimePicker(BuildContext context, TextEditingController timeController) async {
  DateTime now = DateTime.now();
  int roundedMinute = (now.minute / 5).round() * 5;
  if (roundedMinute == 60) {
    now = now.add(const Duration(hours: 1));
    roundedMinute = 0;
  }
  DateTime initialTime = DateTime(
      now.year, now.month, now.day, now.hour, roundedMinute);

  await showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontFamily: 'Jua',
                        color: Colors.grey,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontFamily: 'Jua',
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      final amPm = initialTime.hour < 12 ? '오전' : '오후';
                      final displayHour = initialTime.hour % 12 == 0
                          ? 12
                          : initialTime.hour % 12;
                      timeController.text =
                      '$amPm ${displayHour.toString().padLeft(
                          2, '0')}시 ${initialTime.minute.toString().padLeft(
                          2, '0')}분';
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontFamily: 'Jua',
                      fontSize: 20,
                      color: AppTheme.textPurple,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialTime,
                  use24hFormat: false,
                  minuteInterval: 5,
                  onDateTimeChanged: (DateTime newTime) {
                    initialTime = newTime;
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget buildScheduleDialog(
    BuildContext context,
    TextEditingController titleController,
    TextEditingController dateController,
    TextEditingController timeController,
    TextEditingController memoController,
    Color? selectedColor,
    ValueChanged<Color> onColorSelected,
    VoidCallback onSave,
    {Schedule? existingSchedule} // 추가된 파라미터
    ) {
  final isEdit = existingSchedule != null; // 수정 여부 판단

  return AlertDialog(
    contentPadding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
          _AddScheduleHeader(
            onClose: () => Navigator.of(context).pop(),
            isEdit: isEdit, // 여기서 전달
          ),
          _ScheduleInputField(hint: '일정 제목', controller: titleController),
          const SizedBox(height: 15),
          _ScheduleInputField(
            hint: '날짜',
            controller: dateController,
            onTap: () => onDateTap(context, dateController),
          ),
          const SizedBox(height: 15),
          _ScheduleInputField(
            hint: '시간',
            controller: timeController,
            onTap: () => showCustomTimePicker(context, timeController),
          ),
          const SizedBox(height: 15),
          _ScheduleInputField(hint: '메모(선택)', controller: memoController, maxLines: 3),
          const SizedBox(height: 20),
          _ColorPalette(initialColor: selectedColor, onColorSelected: onColorSelected),
          const SizedBox(height: 30),
          _SaveButton(onSave: onSave),
        ],
      ),
    ),
  );
}

class _AddScheduleHeader extends StatelessWidget {
  final VoidCallback onClose;
  final bool isEdit;

  const _AddScheduleHeader({
    required this.onClose,
    this.isEdit = false, // 기본값 false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            color: AppTheme.textPurple,
          ),
        ),
        Center(
          child: Text(
            isEdit ? '일정 수정' : '일정 추가',
            style: const TextStyle(
              fontFamily: 'Jua',
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPurple,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

class _ScheduleInputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final VoidCallback? onTap;

  const _ScheduleInputField({
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: onTap != null,
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: onTap != null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Jua',
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
          style: const TextStyle(
            fontFamily: 'Jua',
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _ColorPalette extends StatefulWidget {
  final Color? initialColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorPalette({this.initialColor, required this.onColorSelected});

  @override
  State<_ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<_ColorPalette> {
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor ?? AppTheme.primaryPurple;
  }

  Widget _buildColorOption(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
          widget.onColorSelected(color);
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isSelected ? Border.all(color: AppTheme.textPurple, width: 2) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildColorOption(Colors.red),
          _buildColorOption(Colors.orange),
          _buildColorOption(Colors.lightGreen),
          _buildColorOption(Colors.lightBlueAccent),
          _buildColorOption(AppTheme.primaryPurple),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onSave;
  const _SaveButton({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 15.0),
      child: Center(
        child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Text('저장하기', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
