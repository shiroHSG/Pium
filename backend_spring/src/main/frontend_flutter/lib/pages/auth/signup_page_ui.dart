import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

// 기본 입력 필드 위젯
Widget buildSignupInputField(String labelText, TextEditingController controller, TextInputType keyboardType, bool isPassword) {
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
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
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
Widget buildNicknameInputField(String labelText, TextEditingController controller, VoidCallback onDuplicateCheck) {
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
                  fillColor: Colors.white,
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
            onPressed: onDuplicateCheck,
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
Widget buildBirthDateInputField(String labelText, TextEditingController controller, Future<void> Function(BuildContext) onSelectDate) {
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
          readOnly: true,
          onTap: () => onSelectDate(controller.text as BuildContext), // Type cast needed here
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.textPurple),
          ),
          style: const TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua'),
        ),
      ),
    ],
  );
}

// 성별 선택 필드
Widget buildGenderSelectionField(String labelText, String? selectedGender, Function(String?) onGenderChanged) {
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
              onTap: () => onGenderChanged('남성'),
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedGender == '남성' ? AppTheme.primaryPurple : AppTheme.lightPink,
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
                    color: selectedGender == 'M' ? Colors.white : AppTheme.textPurple,
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
              onTap: () => onGenderChanged('여성'),
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedGender == '여성' ? AppTheme.primaryPurple : AppTheme.lightPink,
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
                    color: selectedGender == '여성' ? Colors.white : AppTheme.textPurple,
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
Widget buildAddressInputField(String labelText, TextEditingController controller, VoidCallback onAddressSearch) {
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
                  fillColor: Colors.white,
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
            onPressed: onAddressSearch,
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

class SignupPageUI extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController nicknameController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController birthDateController;
  final TextEditingController addressController;
  final String? selectedGender;
  final VoidCallback onSignup;
  final VoidCallback onDuplicateNicknameCheck;
  final Future<void> Function(BuildContext) onSelectDate;
  final Function(String?) onGenderChanged;
  final VoidCallback onAddressSearch;

  const SignupPageUI({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nicknameController,
    required this.nameController,
    required this.phoneController,
    required this.birthDateController,
    required this.addressController,
    required this.selectedGender,
    required this.onSignup,
    required this.onDuplicateNicknameCheck,
    required this.onSelectDate,
    required this.onGenderChanged,
    required this.onAddressSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            Image.asset(
              'assets/logo1.png',
              width: 100,
            ),
            const SizedBox(height: 15),
            buildSignupInputField('이메일', emailController, TextInputType.emailAddress, false),
            const SizedBox(height: 15),
            buildSignupInputField('비밀번호', passwordController, TextInputType.text, true),
            const SizedBox(height: 15),
            buildSignupInputField('비밀번호 확인', confirmPasswordController, TextInputType.text, true),
            const SizedBox(height: 15),
            buildNicknameInputField('닉네임', nicknameController, onDuplicateNicknameCheck),
            const SizedBox(height: 15),
            buildSignupInputField('이름', nameController, TextInputType.text, false),
            const SizedBox(height: 15),
            buildSignupInputField('전화번호', phoneController, TextInputType.phone, false),
            const SizedBox(height: 15),
            buildBirthDateInputField('생년월일', birthDateController, onSelectDate),
            const SizedBox(height: 15),
            buildGenderSelectionField('성별', selectedGender, onGenderChanged),
            const SizedBox(height: 15),
            buildAddressInputField('주소', addressController, onAddressSearch),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onSignup,
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
    );
  }
}