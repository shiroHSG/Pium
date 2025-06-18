import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../screens/my_page/profile_edit/profile_edit_page_ui.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mateController = TextEditingController();

  String? _originalNickname;
  String? _originalPhoneNumber;
  String? _originalAddress;
  String? _originalMateInfo;

  bool isLoading = true;
  bool isEditing = false;

  String? _profileImageUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
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

        final birthList = user['birth'];
        final birthFormatted = birthList is List
            ? '${birthList[0]}-${birthList[1].toString().padLeft(
            2, '0')}-${birthList[2].toString().padLeft(2, '0')}'
            : '';

        setState(() {
          emailController.text = user['email'] ?? '';
          usernameController.text = user['username'] ?? '';
          nicknameController.text = user['nickname'] ?? '';
          phoneController.text = user['phoneNumber'] ?? '';
          birthController.text = birthFormatted;
          genderController.text = (user['gender'] == 'M') ? '남성' : '여성';
          addressController.text = user['address'] ?? '';
          mateController.text = user['mateInfo']?.toString() ?? '';
          final imagePath = user['profileImageUrl'];
          _profileImageUrl = (imagePath != null && imagePath.isNotEmpty)
              ? 'http://10.0.2.2:8080${imagePath.startsWith('/') ? imagePath : '/$imagePath'}'
              : null;


          _originalNickname = user['nickname'] ?? '';
          _originalPhoneNumber = user['phoneNumber'] ?? '';
          _originalAddress = user['address'] ?? '';
          _originalMateInfo = user['mateInfo']?.toString() ?? '';

          isLoading = false;
        });
      } else {
        print('회원 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
    }
  }

  Future<void> _updateUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final uri = Uri.parse('http://10.0.2.2:8080/api/member');
    final request = http.MultipartRequest('PATCH', uri);

    final memberData = {
      "nickname": nicknameController.text.trim(),
      "phoneNumber": phoneController.text.trim(),
      "address": addressController.text.trim(),
      "mateInfo": mateController.text.trim(),
    };

    request.fields['memberData'] = jsonEncode(memberData);
    request.headers['Authorization'] = 'Bearer $token';

    // 이미지 파일 추가
    if (_selectedImage != null) {
      print('📁 전송할 이미지 경로: ${_selectedImage!.path}');
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
      ));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📨 응답 상태: ${response.statusCode}');
      print('📨 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정이 완료되었습니다.')),
        );

        _originalNickname = nicknameController.text.trim();
        _originalPhoneNumber = phoneController.text.trim();
        _originalAddress = addressController.text.trim();
        _originalMateInfo = mateController.text.trim();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정에 실패했습니다.')),
        );
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('네트워크 오류')),
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
        nameController: nicknameController,
        phoneController: phoneController,
        birthController: birthController,
        genderController: genderController,
        addressController: addressController,
        mateController: mateController,
        isEditing: isEditing,
        profileImageUrl: _profileImageUrl,
        selectedImage: _selectedImage,
        onPickImage: _pickImage,
        onToggleEdit: () async {
          if (!isEditing) {
            setState(() => isEditing = true);
            return;
          }

          final isUnchanged =
              nicknameController.text.trim() == _originalNickname?.trim() &&
                  phoneController.text.trim() == _originalPhoneNumber?.trim() &&
                  addressController.text.trim() == _originalAddress?.trim() &&
                  mateController.text.trim() == _originalMateInfo?.trim() &&
                  _selectedImage == null;

          if (isUnchanged) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('변경사항이 없습니다!')),
            );
          } else {
            await _updateUserInfo();
            Navigator.pop(context, 'updated'); // 수정 완료 후 마이페이지에 알림
            return;
          }

          setState(() => isEditing = false);
        },
      ),
    );
  }
}
