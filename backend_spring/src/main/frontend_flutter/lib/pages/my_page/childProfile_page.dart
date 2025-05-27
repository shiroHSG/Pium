import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/widgets/custom_app_bar.dart';
import 'package:frontend_flutter/widgets/custom_bottom_bar.dart';
import 'package:frontend_flutter/models/child_profile.dart';
import 'package:frontend_flutter/pages/my_page/childProfile_edit_page.dart';

class ChildProfilePage extends StatefulWidget {
  const ChildProfilePage({Key? key}) : super(key: key);

  @override
  State<ChildProfilePage> createState() => _ChildProfilePageState();
}

class _ChildProfilePageState extends State<ChildProfilePage> {
  final List<ChildProfile> _childrenProfiles = [];

  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newDobController = TextEditingController();
  final TextEditingController _newHeightController = TextEditingController();
  final TextEditingController _newWeightController = TextEditingController();
  final TextEditingController _newAllergiesController = TextEditingController();

  String? _selectedGender;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadChildrenProfiles();
  }

  @override
  void dispose() {
    _newNameController.dispose();
    _newDobController.dispose();
    _newHeightController.dispose();
    _newWeightController.dispose();
    _newAllergiesController.dispose();
    super.dispose();
  }

  Future<void> _loadChildrenProfiles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _childrenProfiles.addAll([
        ChildProfile(
          name: '김철수',
          dob: '2018.03.20',
          gender: '남아',
          height: '110cm',
          weight: '18kg',
          allergies: '없음',
        ),
        ChildProfile(
          name: '이영희',
          dob: '2020.07.11',
          gender: '여아',
          height: '95cm',
          weight: '15kg',
          allergies: '우유',
        ),
      ]);
    });
  }

  void _addChildProfile() {
    if (_newNameController.text.isNotEmpty && _newDobController.text.isNotEmpty) {
      setState(() {
        _childrenProfiles.add(
          ChildProfile(
            name: _newNameController.text,
            dob: _newDobController.text,
            gender: _selectedGender,
            height: _newHeightController.text.isEmpty ? null : _newHeightController.text,
            weight: _newWeightController.text.isEmpty ? null : _newWeightController.text,
            allergies: _newAllergiesController.text.isEmpty ? null : _newAllergiesController.text,
          ),
        );
        _newNameController.clear();
        _newDobController.clear();
        _selectedGender = null;
        _newHeightController.clear();
        _newWeightController.clear();
        _newAllergiesController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 아이 프로필이 추가되었습니다!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름과 생년월일을 모두 입력해주세요.'), backgroundColor: Colors.red),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    print('하단 내비게이션 바 - 탭 $index 클릭됨');
  }

  Future<void> _navigateToEditProfile(ChildProfile child) async {
    final updatedChild = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChildProfileEditPage(childProfile: child)),
    );

    if (updatedChild is ChildProfile) {
      setState(() {
        final idx = _childrenProfiles.indexOf(child);
        if (idx != -1) _childrenProfiles[idx] = updatedChild;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이 프로필이 성공적으로 수정되었습니다!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onMenuPressed: () {
          print('메뉴 아이콘 클릭 (CustomAppBar)');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '등록된 아이 정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPurple),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGender = null;
                      });
                      _showAddChildDialog(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 각 아이 프로필 카드를 탭 가능하게 변경
            ..._childrenProfiles.map((child) => GestureDetector(
              onTap: () => _navigateToEditProfile(child), // 탭 시 수정 페이지로 이동
              child: _buildChildProfileCard(child),
            )).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildChildProfileCard(ChildProfile child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: AppTheme.lightPink,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.child_care, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이름: ${child.name}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPurple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '생년월일: ${child.dob}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPurple,
                    ),
                  ),
                  if (child.gender != null && child.gender!.isNotEmpty)
                    Text(
                      '성별: ${child.gender}',
                      style: TextStyle(fontSize: 14, color: AppTheme.textPurple),
                    ),
                  if (child.height != null && child.height!.isNotEmpty)
                    Text(
                      '키: ${child.height}',
                      style: TextStyle(fontSize: 14, color: AppTheme.textPurple),
                    ),
                  if (child.weight != null && child.weight!.isNotEmpty)
                    Text(
                      '몸무게: ${child.weight}',
                      style: TextStyle(fontSize: 14, color: AppTheme.textPurple),
                    ),
                  if (child.allergies != null && child.allergies!.isNotEmpty)
                    Text(
                      '알러지: ${child.allergies}',
                      style: TextStyle(fontSize: 14, color: AppTheme.textPurple),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddChildDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('새 아이 정보 추가'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogInputField(
                        controller: _newNameController,
                        labelText: '이름',
                        hintText: '아이 이름',
                        labelPadding: const EdgeInsets.only(bottom: 10),
                      ),
                      const SizedBox(height: 15),
                      _buildDialogInputField(
                        controller: _newDobController,
                        labelText: '생년월일',
                        hintText: 'YYYY.MM.DD',
                        keyboardType: TextInputType.datetime,
                        labelPadding: const EdgeInsets.only(bottom: 10),
                        isNumeric: true, // 숫자만 허용하도록 설정
                        // 생년월일은 YYYY.MM.DD 형식 유지 및 숫자만 허용
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '생년월일을 입력해주세요.';
                          }
                          // YYYY.MM.DD 형식만 허용 (숫자와 점만)
                          if (!RegExp(r'^\d{4}\.\d{2}\.\d{2}$').hasMatch(value)) {
                            return 'YYYY.MM.DD 형식으로 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildGenderSelection(
                        selectedGender: _selectedGender,
                        onChanged: (gender) {
                          setState(() {
                            _selectedGender = gender;
                          });
                        },
                        labelPadding: const EdgeInsets.only(bottom: 10),
                      ),
                      const SizedBox(height: 15),
                      _buildDialogInputField(
                        controller: _newHeightController,
                        labelText: '키',
                        hintText: '예: 100cm',
                        keyboardType: TextInputType.number,
                        labelPadding: const EdgeInsets.only(bottom: 10),
                        isNumeric: true, // 숫자만 허용하도록 설정
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                            return '숫자만 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildDialogInputField(
                        controller: _newWeightController,
                        labelText: '몸무게',
                        hintText: '예: 15kg',
                        keyboardType: TextInputType.number,
                        labelPadding: const EdgeInsets.only(bottom: 10),
                        isNumeric: true, // 숫자만 허용하도록 설정
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                            return '숫자만 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildDialogInputFieldWithHint(
                        controller: _newAllergiesController,
                        labelText: '알러지',
                        hintText: '예: 우유, 땅콩',
                        bottomHintText: '없으면 "없음"으로 입력하세요.',
                        labelPadding: const EdgeInsets.only(bottom: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('취소', style: TextStyle(color: AppTheme.primaryPurple)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addChildProfile();
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  // 텍스트 필드와 레이블 간격 조정을 위한 헬퍼 함수
  Widget _buildDialogInputField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsetsGeometry labelPadding = EdgeInsets.zero,
    bool isNumeric = false, // 숫자만 허용할지 여부를 위한 새 매개변수
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: labelPadding,
          child: Text(
            labelText,
            style: TextStyle(
              color: AppTheme.textPurple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
            errorBorder: OutlineInputBorder( // 에러 시 테두리 색상
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          ),
          style: TextStyle(color: AppTheme.textPurple),
        ),
      ],
    );
  }

  Widget _buildDialogInputFieldWithHint({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    required String bottomHintText,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsetsGeometry labelPadding = EdgeInsets.zero,
    bool isNumeric = false, // 숫자만 허용할지 여부를 위한 새 매개변수
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: labelPadding,
          child: Text(
            labelText,
            style: TextStyle(
              color: AppTheme.textPurple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          ),
          style: TextStyle(color: AppTheme.textPurple),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            bottomHintText,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection({
    required String? selectedGender,
    required ValueChanged<String?> onChanged,
    EdgeInsetsGeometry labelPadding = EdgeInsets.zero,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: labelPadding,
          child: const Text(
            '성별',
            style: TextStyle(
              color: AppTheme.textPurple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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