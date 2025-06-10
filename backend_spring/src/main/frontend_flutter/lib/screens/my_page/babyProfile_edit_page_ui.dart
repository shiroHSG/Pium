import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class EditInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const EditInputField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: AppTheme.textPurple,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppTheme.textPurple.withOpacity(0.6)),
            filled: true,
            fillColor: AppTheme.lightPink,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          ),
          style: const TextStyle(color: AppTheme.textPurple),
        ),
      ],
    );
  }
}

class GenderSelectionForEdit extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String?> onChanged;

  const GenderSelectionForEdit({
    Key? key,
    required this.selectedGender,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '성별',
          style: TextStyle(
            color: AppTheme.textPurple,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('남아'),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: selectedGender == '남아' ? AppTheme.primaryPurple : AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedGender == '남아' ? AppTheme.primaryPurple : Colors.transparent,
                      width: selectedGender == '남아' ? 2 : 0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '남아',
                      style: TextStyle(
                        color: selectedGender == '남아' ? Colors.white : AppTheme.textPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('여아'),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: selectedGender == '여아' ? AppTheme.primaryPurple : AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedGender == '여아' ? AppTheme.primaryPurple : Colors.transparent,
                      width: selectedGender == '여아' ? 2 : 0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '여아',
                      style: TextStyle(
                        color: selectedGender == '여아' ? Colors.white : AppTheme.textPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}