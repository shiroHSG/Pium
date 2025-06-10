import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class AddScheduleHeader extends StatelessWidget {
  final VoidCallback onClose;

  const AddScheduleHeader({Key? key, required this.onClose}) : super(key: key);

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
            style: TextStyle(
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

class ScheduleInputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final VoidCallback? onTap;

  const ScheduleInputField({
    Key? key,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.onTap,
  }) : super(key: key);

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

class ColorPalette extends StatefulWidget {
  final Color? initialColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPalette({Key? key, this.initialColor, required this.onColorSelected}) : super(key: key);

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
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
          border: isSelected
              ? Border.all(color: AppTheme.textPurple, width: 2)
              : null,
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

class AddScheduleButton extends StatelessWidget {
  final VoidCallback onSave;

  const AddScheduleButton({Key? key, required this.onSave}) : super(key: key);

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