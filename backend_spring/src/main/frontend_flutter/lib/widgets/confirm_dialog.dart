import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ConfirmDialog extends StatelessWidget {
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmDialog({
    Key? key,
    required this.content,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = '예',
    this.cancelText = '아니오',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 55.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.textPurple,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(context, confirmText, onConfirm), // 예 버튼
                const SizedBox(width: 20),
                _buildButton(
                  context,
                  cancelText,
                      () {
                    if (onCancel != null) onCancel!();
                  },
                  shouldCloseDialog: true,
                ), // 아니오 버튼
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed, {bool shouldCloseDialog = true}) {
    return SizedBox(
      width: 80,
      height: 36,
      child: ElevatedButton(
        onPressed: () {
          if (shouldCloseDialog) Navigator.of(context).pop();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
