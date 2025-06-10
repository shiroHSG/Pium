import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/screens/my_page/profile_edit_page_ui.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPurple),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '프로필 수정',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: const ProfileEditPageUI(),
    );
  }
}