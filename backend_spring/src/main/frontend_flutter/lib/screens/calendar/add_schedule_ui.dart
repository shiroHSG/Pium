import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

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

void showCustomTimePicker(BuildContext context, TextEditingController timeController) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      int selectedHour = DateTime.now().hour;
      int selectedMinute = DateTime.now().minute;

      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(16),
            height: 250,
            child: Column(
              children: [
                const Text('시간 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      value: selectedHour,
                      items: List.generate(
                        24,
                            (index) => DropdownMenuItem(
                          value: index,
                          child: Text('$index시'),
                        ),
                      ),
                      onChanged: (value) => setState(() => selectedHour = value!),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: selectedMinute,
                      items: List.generate(
                        60,
                            (index) => DropdownMenuItem(
                          value: index,
                          child: Text('$index분'),
                        ),
                      ),
                      onChanged: (value) => setState(() => selectedMinute = value!),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    timeController.text = '$selectedHour시 $selectedMinute분';
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        },
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
    ) {
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
          _AddScheduleHeader(onClose: () => Navigator.of(context).pop()),
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
  const _AddScheduleHeader({required this.onClose});

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
        const Center(
          child: Text(
            '일정 추가',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: AppTheme.textPurple),
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
            hintStyle: TextStyle(color: Colors.grey[700]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
          style: const TextStyle(color: Colors.black87),
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
