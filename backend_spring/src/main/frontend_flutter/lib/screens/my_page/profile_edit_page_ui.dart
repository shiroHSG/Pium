import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class ProfileEditPageUI extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController birthController;
  final TextEditingController genderController;
  final TextEditingController addressController;
  final TextEditingController mateController;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  const ProfileEditPageUI({
    Key? key,
    required this.emailController,
    required this.usernameController,
    required this.nameController,
    required this.phoneController,
    required this.birthController,
    required this.genderController,
    required this.addressController,
    required this.mateController,
    required this.isEditing,
    required this.onToggleEdit,
  }) : super(key: key);

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
          '프로필',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _ProfileEditHeader(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  _buildProfileInputField(label: '이메일', controller: emailController, readOnly: true),
                  _buildProfileInputField(label: '아이디', controller: usernameController, readOnly: true),
                  _buildProfileInputField(label: '성별', controller: genderController, readOnly: true),
                  _buildProfileInputField(label: '이름', controller: nameController, readOnly: !isEditing),
                  _buildProfileInputField(label: '전화번호', controller: phoneController, keyboardType: TextInputType.phone, readOnly: !isEditing),
                  _buildProfileInputField(label: '생년월일', controller: birthController, keyboardType: TextInputType.datetime, readOnly: !isEditing),
                  _buildProfileInputField(label: '주소', controller: addressController, readOnly: !isEditing),
                  _buildProfileInputField(label: '배우자', controller: mateController, readOnly: !isEditing),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onToggleEdit,
                      child: Text(
                        isEditing ? '완료' : '수정하기',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    IconData? suffixIcon,
  }) {
    final Color fieldColor = (readOnly ? AppTheme.primaryPurple : AppTheme.lightPink);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPurple,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: readOnly,
              style: const TextStyle(color: AppTheme.textPurple),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                fillColor: fieldColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: suffixIcon != null
                    ? Icon(suffixIcon, color: AppTheme.textPurple)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEditHeader extends StatelessWidget {
  const _ProfileEditHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      decoration: const BoxDecoration(
        color: AppTheme.lightPink,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              color: AppTheme.primaryPurple,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
