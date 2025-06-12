import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_flutter/theme/app_theme.dart';

import '../../screens/my_page/profile_edit_page_ui.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mateController = TextEditingController();

  String? _originalNickname;
  String? _originalPhoneNumber;
  String? _originalBirth;
  String? _originalAddress;
  String? _originalMateInfo;

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

          _originalNickname = user['nickname'] ?? '';
          _originalPhoneNumber = user['phoneNumber'] ?? '';
          _originalBirth = user['birth'] ?? '';
          _originalAddress = user['address'] ?? '';
          _originalMateInfo = user['mateInfo'] ?? '';

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

      // 최신값으로 다시 저장
      _originalNickname = nameController.text.trim();
      _originalPhoneNumber = phoneController.text.trim();
      _originalBirth = birthController.text.trim();
      _originalAddress = addressController.text.trim();
      _originalMateInfo = mateController.text.trim();
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ProfileEditPageUI(
        emailController: emailController,
        usernameController: usernameController,
        nameController: nameController,
        phoneController: phoneController,
        birthController: birthController,
        genderController: genderController,
        addressController: addressController,
        mateController: mateController,
        isEditing: isEditing,
        onToggleEdit: () async {
          if (!isEditing) {
            // 수정 모드 진입
            setState(() => isEditing = true);
            return;
          }
          // 수정 완료 상태
          final isUnchanged =
              nameController.text.trim() == _originalNickname?.trim() &&
                  phoneController.text.trim() == _originalPhoneNumber?.trim() &&
                  birthController.text.trim() == _originalBirth?.trim() &&
                  addressController.text.trim() == _originalAddress?.trim() &&
                  mateController.text.trim() == _originalMateInfo?.trim();

          if (isUnchanged) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('변경사항이 없습니다!')),
            );
          } else {
            await _updateUserInfo();
          }

          setState(() => isEditing = false);
        },
      ),
    );
  }

  TextEditingController get getNameController => nameController;
  TextEditingController get getPhoneController => phoneController;
  TextEditingController get getBirthController => birthController;
  TextEditingController get getAddressController => addressController;
  TextEditingController get getMateController => mateController;
  bool get getIsEditing => isEditing;
  void toggleEditing() => setState(() => isEditing = !isEditing);
  Future<void> submitUpdate() async => await _updateUserInfo();
}

