import 'package:flutter/material.dart';

class InviteModalUI extends StatelessWidget {
  final String chatRoomName;
  final TextEditingController passwordController;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;

  const InviteModalUI({
    super.key,
    required this.chatRoomName,
    required this.passwordController,
    required this.onConfirm,
    required this.onCancel,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              chatRoomName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('비밀번호를 입력해주세요.'),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: onCancel, child: const Text('취소')),
                  ElevatedButton(onPressed: onConfirm, child: const Text('입장')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
