import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import '../../screens/auth/signup_page_ui.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // 텍스트 필드 컨트롤러들
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedGender;

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    required String nickname,
    required String phoneNumber,
    required String address,
    required String birth,
    required String? gender,
  })
  async {
    final url = Uri.parse('http://10.0.2.2:8080/api/member/register'); // baseUrl 정의되어 있어야 함

    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
      'nickname': nickname,
      'phoneNumber': phoneNumber,
      'address': address,
      'birth': birth,
      'gender': gender,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('회원가입 실패: ${response.statusCode}');
      print('응답 내용: ${response.body}');
      return false;
    }
  }
  void _signup() async {
    print("_signUp 실행");
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    final success = await signup(
      username: _emailController.text,
      email: _emailController.text,
      password: _passwordController.text,
      nickname: _nicknameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      birth: _birthDateController.text,
      gender: _selectedGender == '남성' ? 'M' : 'F',
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 성공!')),
      );
      // 다음 화면 이동
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 실패')),
      );
    }
  }

  void _checkNicknameDuplicate() {
    print('닉네임 중복 확인: ${_nicknameController.text}');
    // 실제 닉네임 중복 확인 로직 구현 필요
    // 예시: 서버에 닉네임 존재 여부 확인 요청
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPurple,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryPurple,
              ),
            ),
            textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Jua',
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _searchAddress() {
    print('주소 검색');
    // 실제 주소 검색 로직 (API 호출, 페이지 이동 등) 구현 필요
  }

  void _handleGenderChanged(String? gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPurple),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: SignupPageUI(
        emailController: _emailController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        nicknameController: _nicknameController,
        nameController: _nameController,
        phoneController: _phoneController,
        birthDateController: _birthDateController,
        addressController: _addressController,
        selectedGender: _selectedGender,
        onSignup: _signup,
        onDuplicateNicknameCheck: _checkNicknameDuplicate,
        onSelectDate: _selectDate,
        onGenderChanged: _handleGenderChanged,
        onAddressSearch: _searchAddress,
      ),
    );
  }
}