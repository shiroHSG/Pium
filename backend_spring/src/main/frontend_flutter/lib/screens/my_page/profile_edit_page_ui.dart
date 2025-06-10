import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class ProfileEditPageUI extends StatelessWidget {
  const ProfileEditPageUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const _ProfileEditHeader(),
          const SizedBox(height: 30),
          const _ProfileEditForm(),
          const SizedBox(height: 30),
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

class _ProfileEditForm extends StatelessWidget {
  const _ProfileEditForm();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          _buildProfileInputField(label: '이메일', initialValue: 'user@example.com'),
          _buildProfileInputField(label: '아이디', initialValue: 'user_id'),
          _buildProfileInputField(label: '이름', initialValue: '홍길동'),
          _buildProfileInputField(label: '전화번호', initialValue: '010-1234-5678', keyboardType: TextInputType.phone),
          _buildProfileInputField(label: '생년월일', initialValue: 'YYYY.MM.DD', keyboardType: TextInputType.datetime),
          _buildProfileInputField(label: '성별', initialValue: '여성', readOnly: true, suffixIcon: Icons.arrow_drop_down),
          _buildProfileInputField(label: '주소', initialValue: '서울특별시 강남구'),
          _buildProfileInputField(label: '배우자', initialValue: '김철수'),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                print('수정하기 버튼 클릭됨');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2,
              ),
              child: const Text(
                '수정하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInputField({
    required String label,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    IconData? suffixIcon,
  }) {
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
              controller: TextEditingController(text: initialValue),
              keyboardType: keyboardType,
              readOnly: readOnly,
              style: const TextStyle(color: AppTheme.textPurple),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                fillColor: AppTheme.primaryPurple,
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