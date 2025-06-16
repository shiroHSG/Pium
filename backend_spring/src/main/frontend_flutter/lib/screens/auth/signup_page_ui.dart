import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

// 라벨 텍스트 스타일
Widget buildLabelText(String label) {
  return Text(
    label,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppTheme.textPurple,
      fontFamily: 'Jua',
    ),
  );
}

// 기본 텍스트 필드 컨테이너
Widget buildTextFieldContainer({
  required TextEditingController controller,
  bool isPassword = false,
  bool readOnly = false,
  VoidCallback? onTap,
  Widget? suffixIcon,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Container(
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
      obscureText: isPassword,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua'),
    ),
  );
}

// 이메일, 비밀번호, 이름 등 기본 필드
Widget buildSignupInputField(String label, TextEditingController controller, TextInputType type, bool isPassword) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildLabelText(label),
      const SizedBox(height: 8),
      buildTextFieldContainer(controller: controller, keyboardType: type, isPassword: isPassword),
    ],
  );
}

// 닉네임 필드 + 중복확인
Widget buildNicknameInputField(String label, TextEditingController controller, VoidCallback onCheck) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildLabelText(label),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: buildTextFieldContainer(controller: controller)),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onCheck,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              minimumSize: const Size(100, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('중복 확인', style: TextStyle(color: Colors.white, fontFamily: 'Jua')),
          ),
        ],
      ),
    ],
  );
}

// 생년월일 필드
Widget buildBirthDateInputField(String label, TextEditingController controller, Future<void> Function(BuildContext) onSelect) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildLabelText(label),
      const SizedBox(height: 8),
      buildTextFieldContainer(
        controller: controller,
        readOnly: true,
        onTap: () => onSelect.call(controller as BuildContext),
        suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.textPurple),
      ),
    ],
  );
}

// 성별 선택 필드
Widget buildGenderSelectionField(String label, String? selected, Function(String?) onChange) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildLabelText(label),
      const SizedBox(height: 8),
      Row(
        children: ['남성', '여성'].map((gender) {
          final isSelected = gender == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChange(gender),
              child: Container(
                height: 50,
                margin: EdgeInsets.only(right: gender == '남성' ? 10 : 0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryPurple : AppTheme.lightPink,
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
                  gender,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPurple,
                    fontFamily: 'Jua',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

// 주소 필드 + 검색 버튼
Widget buildAddressInputField(String label, TextEditingController controller, VoidCallback onSearch) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildLabelText(label),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: buildTextFieldContainer(controller: controller, readOnly: true),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              minimumSize: const Size(100, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('주소 검색', style: TextStyle(color: Colors.white, fontFamily: 'Jua')),
          ),
        ],
      ),
    ],
  );
}

// 회원가입 페이지 UI
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
            Image.asset('assets/logo1.png', width: 100),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                '회원가입',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Jua'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
