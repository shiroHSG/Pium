// lib/pages/signup_page.dart

import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

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

  String? _selectedGender; // 성별 선택을 위한 변수

  void _signup() {
    // 회원가입 로직 구현
    print('이메일: ${_emailController.text}');
    print('비밀번호: ${_passwordController.text}');
    print('닉네임: ${_nicknameController.text}');
    print('이름: ${_nameController.text}');
    print('전화번호: ${_phoneController.text}');
    print('생년월일: ${_birthDateController.text}');
    print('성별: $_selectedGender');
    print('주소: ${_addressController.text}');

    // 비밀번호 확인 로직
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }
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
              primary: AppTheme.primaryPurple, // 달력 헤더 배경색
              onPrimary: Colors.white, // 달력 헤더 텍스트 색상
              onSurface: AppTheme.textPurple, // 달력 숫자/요일 색상
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryPurple, // '확인', '취소' 버튼 색상
              ),
            ),
            // 이곳을 수정합니다.
            textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Jua', // 모든 텍스트 스타일에 fontFamily 적용
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightPink, // 배경색을 AppTheme.lightPink로 설정
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar 배경 투명하게
        elevation: 0, // AppBar 그림자 제거
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPurple), // 뒤로가기 버튼
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15), // 로고 위 여백 줄임
              // 피움 로고
              Image.asset(
                'assets/logo1.png',
                width: 100,
              ),
              const SizedBox(height: 15), // 로고 아래 여백 줄임
              _buildSignupInputField('이메일', _emailController, TextInputType.emailAddress, false),
              const SizedBox(height: 15),
              _buildSignupInputField('비밀번호', _passwordController, TextInputType.text, true),
              const SizedBox(height: 15),
              _buildSignupInputField('비밀번호 확인', _confirmPasswordController, TextInputType.text, true),
              const SizedBox(height: 15),
              _buildNicknameInputField('닉네임', _nicknameController), // 중복 확인 버튼 포함
              const SizedBox(height: 15),
              _buildSignupInputField('이름', _nameController, TextInputType.text, false),
              const SizedBox(height: 15),
              _buildSignupInputField('전화번호', _phoneController, TextInputType.phone, false),
              const SizedBox(height: 15),
              _buildBirthDateInputField('생년월일', _birthDateController), // 생년월일 필드에는 달력 아이콘 포함
              const SizedBox(height: 15),
              _buildGenderSelectionField('성별'),
              const SizedBox(height: 15),
              _buildAddressInputField('주소', _addressController), // 주소 필드에는 '주소 검색' 버튼 포함
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Jua',
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 기본 입력 필드 위젯
  Widget _buildSignupInputField(String labelText, TextEditingController controller, TextInputType keyboardType, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPurple,
            fontFamily: 'Jua',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightPink, // 배경색
            borderRadius: BorderRadius.circular(10), // 모서리 둥글게
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
            style: const TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua'),
          ),
        ),
      ],
    );
  }

  // 닉네임 입력 필드 (중복 확인 버튼 포함)
  Widget _buildNicknameInputField(String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPurple,
            fontFamily: 'Jua',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightPink,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  ),
                  style: const TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                print('닉네임 중복 확인: ${controller.text}');
                // 닉네임 중복 확인 로직
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                minimumSize: const Size(100, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '중복 확인',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jua',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 생년월일 입력 필드 (달력 아이콘 포함)
  Widget _buildBirthDateInputField(String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPurple,
            fontFamily: 'Jua',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightPink,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: true, // 직접 입력 방지
            onTap: () => _selectDate(context), // 탭 시 달력 표시
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.textPurple), // 달력 아이콘
            ),
            style: const TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua'),
          ),
        ),
      ],
    );
  }

  // 성별 선택 필드
  Widget _buildGenderSelectionField(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPurple,
            fontFamily: 'Jua',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = '남성';
                  });
                },
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedGender == '남성' ? AppTheme.primaryPurple : AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '남성',
                    style: TextStyle(
                      color: _selectedGender == '남성' ? Colors.white : AppTheme.textPurple,
                      fontFamily: 'Jua',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = '여성';
                  });
                },
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedGender == '여성' ? AppTheme.primaryPurple : AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '여성',
                    style: TextStyle(
                      color: _selectedGender == '여성' ? Colors.white : AppTheme.textPurple,
                      fontFamily: 'Jua',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 주소 입력 필드 (주소 검색 버튼 포함)
  Widget _buildAddressInputField(String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPurple,
            fontFamily: 'Jua',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightPink,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  readOnly: true, // 주소는 직접 입력 방지
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  ),
                  style: const TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                print('주소 검색');
                // 주소 검색 API 호출 또는 페이지 이동 로직
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                minimumSize: const Size(100, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '주소 검색',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jua',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}