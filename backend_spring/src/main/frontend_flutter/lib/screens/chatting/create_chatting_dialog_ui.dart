// lib/widgets/chat/create_chatting_dialog_ui.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';

class CreateChattingDialogUI extends StatelessWidget {
  final TextEditingController chatRoomNameController;
  final TextEditingController passwordController;
  final File? selectedImage;
  final bool isLoading;
  final VoidCallback onCreatePressed;
  final VoidCallback onPickImage;

  const CreateChattingDialogUI({
    Key? key,
    required this.chatRoomNameController,
    required this.passwordController,
    required this.selectedImage,
    required this.isLoading,
    required this.onCreatePressed,
    required this.onPickImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.pink[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '채팅방 생성',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPurple,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textPurple),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: onPickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage:
                selectedImage != null ? FileImage(selectedImage!) : null,
                child: selectedImage == null
                    ? const Icon(Icons.camera_alt, color: AppTheme.textPurple, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: chatRoomNameController,
              decoration: InputDecoration(
                hintText: '채팅방 이름',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호 (선택)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onCreatePressed,
              child: const Text('생성하기', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
