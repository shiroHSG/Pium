import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'signup_page_ui.dart'; // Import the new UI widget

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

  void _signup() {
    print('이메일: ${_emailController.text}');
    print('비밀번호: ${_passwordController.text}');
    print('닉네임: ${_nicknameController.text}');
    print('이름: ${_nameController.text}');
    print('전화번호: ${_phoneController.text}');
    print('생년월일: ${_birthDateController.text}');
    print('성별: $_selectedGender');
    print('주소: ${_addressController.text}');

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }
    // 실제 회원가입 로직 구현 필요
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