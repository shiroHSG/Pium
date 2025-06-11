import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_flutter/theme/app_theme.dart';

class ProfileEditPageUI extends StatefulWidget {
  const ProfileEditPageUI({Key? key}) : super(key: key);

  @override
  State<ProfileEditPageUI> createState() => _ProfileEditPageUIState();
}

class _ProfileEditPageUIState extends State<ProfileEditPageUI> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mateController = TextEditingController();

  bool isLoading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/member'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final user = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          emailController.text = user['email'] ?? '';
          usernameController.text = user['username'] ?? '';
          nameController.text = user['nickname'] ?? '';
          phoneController.text = user['phoneNumber'] ?? '';
          birthController.text = user['birth'] ?? '';
          genderController.text = (user['gender'] == 'M') ? '남성' : '여성';
          addressController.text = user['address'] ?? '';
          mateController.text = user['mateInfo'] ?? '';
          isLoading = false;
        });
      } else {
        print('회원 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  Future<void> _updateUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final response = await http.patch(
      Uri.parse('http://10.0.2.2:8080/api/member/edit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "nickname": nameController.text.trim(),
        "phoneNumber": phoneController.text.trim(),
        "birth": birthController.text.trim(),
        "address": addressController.text.trim(),
        "mateInfo": mateController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      print("회원 정보 수정 성공!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정이 완료되었습니다.')),
      );
    } else {
      print("수정 실패: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
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
                _buildProfileInputField(label: '이름', controller: nameController, readOnly: !isEditing),
                _buildProfileInputField(label: '전화번호', controller: phoneController, keyboardType: TextInputType.phone, readOnly: !isEditing),
                _buildProfileInputField(label: '생년월일', controller: birthController, keyboardType: TextInputType.datetime, readOnly: !isEditing),
                _buildProfileInputField(label: '성별', controller: genderController, readOnly: true, suffixIcon: Icons.arrow_drop_down),
                _buildProfileInputField(label: '주소', controller: addressController, readOnly: !isEditing),
                _buildProfileInputField(label: '배우자', controller: mateController, readOnly: !isEditing),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isEditing) {
                        print('수정된 정보 저장');
                        await _updateUserInfo();
                      }

                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
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
    );
  }

  Widget _buildProfileInputField({
    required String label,
    required TextEditingController controller,
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
              controller: controller,
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
