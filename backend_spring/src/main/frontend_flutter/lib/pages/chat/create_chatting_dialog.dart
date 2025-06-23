import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../screens/chatting/create_chatting_dialog_ui.dart';
import '../../models/chat/chat_service.dart';

class CreateChattingDialog extends StatefulWidget {
  const CreateChattingDialog({Key? key}) : super(key: key);

  @override
  State<CreateChattingDialog> createState() => _CreateChattingDialogState();
}

class _CreateChattingDialogState extends State<CreateChattingDialog> {
  final TextEditingController _chatRoomNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createGroupChat() async {
    final name = _chatRoomNameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('채팅방 이름을 입력해주세요.')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      await createGroupChatRoom(
        chatRoomName: name,
        password: password.isNotEmpty ? password : null,
        imageFile: _selectedImage,
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('생성 실패: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CreateChattingDialogUI(
      chatRoomNameController: _chatRoomNameController,
      passwordController: _passwordController,
      selectedImage: _selectedImage,
      isLoading: _isLoading,
      onCreatePressed: _createGroupChat,
      onPickImage: _pickImage,
    );
  }
}
