import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/child_profile.dart';

class ChildProfileEditPage extends StatefulWidget {
  final ChildProfile childProfile;
  const ChildProfileEditPage({Key? key, required this.childProfile}) : super(key: key);

  @override
  State<ChildProfileEditPage> createState() => _ChildProfileEditPageState();
}

class _ChildProfileEditPageState extends State<ChildProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _allergiesController;

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController     = TextEditingController(text: widget.childProfile.name);
    _dobController      = TextEditingController(text: widget.childProfile.dob);
    _heightController   = TextEditingController(text: widget.childProfile.height ?? '');
    _weightController   = TextEditingController(text: widget.childProfile.weight ?? '');
    _allergiesController= TextEditingController(text: widget.childProfile.allergies ?? '');
    _selectedGender     = widget.childProfile.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updated = widget.childProfile.copyWith(
        name: _nameController.text,
        dob: _dobController.text,
        gender: _selectedGender,
        height: _heightController.text.isEmpty ? null : _heightController.text,
        weight: _weightController.text.isEmpty ? null : _weightController.text,
        allergies: _allergiesController.text.isEmpty ? null : _allergiesController.text,
      );
      Navigator.pop(context, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPurple),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '아이정보 수정 페이지', // 앱바 제목
          style: TextStyle(
            color: AppTheme.textPurple,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.textPurple),
            onPressed: () {
              print('알림 아이콘 클릭됨');
              // TODO: 알림 페이지로 이동 또는 알림 기능 구현
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.textPurple),
            onPressed: () {
              print('목록 아이콘 클릭됨');
              // TODO: 목록 페이지로 이동 또는 관련 기능 구현
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // 프로필 이미지 영역
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.child_care, color: Colors.white, size: 80),
                  ),
                ),
                const SizedBox(height: 40),
                // 이름 입력 필드
                _buildEditInputField(
                  controller: _nameController,
                  labelText: '이름',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // 생년월일 입력 필드
                _buildEditInputField(
                  controller: _dobController,
                  labelText: '생년월일',
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '생년월일을 입력해주세요.';
                    }
                    if (!RegExp(r'^\d{4}\.\d{2}\.\d{2}$').hasMatch(value)) {
                      return 'YYYY.MM.DD 형식으로 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // 성별 선택
                _buildGenderSelectionForEdit(
                  selectedGender: _selectedGender,
                  onChanged: (gender) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // 키 입력 필드
                _buildEditInputField(
                  controller: _heightController,
                  labelText: '키',
                  hintText: '예: 110cm',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                      return '숫자만 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // 몸무게 입력 필드
                _buildEditInputField(
                  controller: _weightController,
                  labelText: '몸무게',
                  hintText: '예: 18kg',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                      return '숫자만 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // 알러지 입력 필드
                _buildEditInputField(
                  controller: _allergiesController,
                  labelText: '알러지',
                  hintText: '예: 우유, 땅콩',
                ),
                const SizedBox(height: 40),
                // 수정하기 버튼
                ElevatedButton(
                  onPressed: _saveProfile, // 저장 함수 호출
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '수정하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 아이 정보 수정 페이지용 텍스트 필드 헬퍼 함수
  Widget _buildEditInputField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator, // 유효성 검사기 추가
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: AppTheme.textPurple,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppTheme.textPurple.withOpacity(0.6)),
            filled: true,
            fillColor: AppTheme.lightPink,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          ),
          style: const TextStyle(color: AppTheme.textPurple),
        ),
      ],
    );
  }

  // 아이 정보 수정 페이지용 성별 선택 헬퍼 함수
  Widget _buildGenderSelectionForEdit({
    required String? selectedGender,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '성별',
          style: TextStyle(
            color: AppTheme.textPurple,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('남아'),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: selectedGender == '남아' ? AppTheme.primaryPurple : AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedGender == '남아' ? AppTheme.primaryPurple : Colors.transparent,
                      width: selectedGender == '남아' ? 2 : 0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '남아',
                      style: TextStyle(
                        color: selectedGender == '남아' ? Colors.white : AppTheme.textPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('여아'),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: selectedGender == '여아' ? AppTheme.primaryPurple : AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedGender == '여아' ? AppTheme.primaryPurple : Colors.transparent,
                      width: selectedGender == '여아' ? 2 : 0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '여아',
                      style: TextStyle(
                        color: selectedGender == '여아' ? Colors.white : AppTheme.textPurple,
                        fontWeight: FontWeight.bold,
                      ),
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
}