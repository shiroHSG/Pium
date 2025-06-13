import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:frontend_flutter/models/child/child_api.dart';
import 'package:frontend_flutter/pages/my_page/babyProfile_edit_page.dart';
import 'package:frontend_flutter/screens/my_page/babyProfile_ui.dart';

class BabyProfilePage extends StatefulWidget {
  const BabyProfilePage({Key? key}) : super(key: key);

  @override
  State<BabyProfilePage> createState() => _BabyProfilePageState();
}

class _BabyProfilePageState extends State<BabyProfilePage> {
  List<BabyProfile> _babyProfiles = [];

  @override
  void initState() {
    super.initState();
    _fetchChildProfiles(); // 페이지 진입 시 아이 정보 불러오기
  }

  // 전체 아이 프로필 가져오기
  Future<void> _fetchChildProfiles() async {
    final children = await ChildApi.fetchMyChildren();
    if (children != null) {
      setState(() {
        _babyProfiles.clear();
        _babyProfiles.addAll(children);
      });
    }
  }

  // 아이 수정 페이지로 이동
  Future<void> _navigateToEditProfile(BabyProfile baby) async {
    final updated = await Navigator.push<BabyProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => BabyProfileEditPage(babyProfile: baby),
      ),
    );
    print('[DEBUG] 수정 진입 : ${baby.childId}');
    if (updated != null) {
      final success = await ChildApi.updateMyChild(updated);
      if (success) {
        await _fetchChildProfiles(); // 수정 후 최신 정보 불러오기
        _showSnack('수정되었습니다!');
      } else {
        _showSnack('서버와 통신 중 오류가 발생했습니다.', isError: true);
      }
    }
  }

  // 아이 추가 API 호출
  void _addBabyProfile(BabyProfile newProfile) async {
    final success = await ChildApi.addMyChild(newProfile);
    if (success) {
      await _fetchChildProfiles();
      _showSnack('새 아이 프로필이 추가되었습니다!');
    } else {
      _showSnack('아이 추가에 실패했습니다.', isError: true);
    }
  }

  // 추가 다이얼로그 표시
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => _AddBabyProfileDialog(onProfileAdded: _addBabyProfile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이 프로필', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BabyProfileUI(
        babyProfiles: _babyProfiles,
        onEdit: _navigateToEditProfile,
        onAdd: _showAddDialog,
      ),
    );
  }

  // 하단 스낵바 표시
  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }
}

// 아이 추가 다이얼로그 위젯
class _AddBabyProfileDialog extends StatefulWidget {
  final Function(BabyProfile) onProfileAdded;

  const _AddBabyProfileDialog({required this.onProfileAdded});

  @override
  State<_AddBabyProfileDialog> createState() => _AddBabyProfileDialogState();
}

class _AddBabyProfileDialogState extends State<_AddBabyProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedBirthDate;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergyController = TextEditingController();
  Gender? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  // 생년월일 선택기
  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2020),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('새 아이 정보 추가'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _textField(_nameController, '이름', '아이 이름'),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _pickBirthDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedBirthDate != null
                            ? DateFormat('yyyy.MM.dd').format(_selectedBirthDate!)
                            : '생년월일 선택',
                        style: const TextStyle(fontSize: 14, color: AppTheme.textPurple),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today, color: AppTheme.textPurple),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // 성별 선택
              Row(
                children: Gender.values.map((gender) {
                  final isSelected = _selectedGender == gender;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGender = gender),
                      child: Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryPurple : AppTheme.lightPink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            gender == Gender.MALE ? '남아' : '여아',
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              _textField(_heightController, '키(cm)', '예: 100', isNumber: true),
              const SizedBox(height: 15),
              _textField(_weightController, '몸무게(kg)', '예: 15', isNumber: true),
              const SizedBox(height: 15),
              _textField(_allergyController, '알러지', '없으면 "없음"'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('취소', style: TextStyle(color: AppTheme.primaryPurple)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate() &&
                _selectedBirthDate != null &&
                _selectedGender != null) {
              final profile = BabyProfile(
                name: _nameController.text,
                birthDate: _selectedBirthDate!,
                gender: _selectedGender!,
                height: _heightController.text.isEmpty
                    ? null
                    : double.tryParse(_heightController.text),
                weight: _weightController.text.isEmpty
                    ? null
                    : double.tryParse(_weightController.text),
                allergy: _allergyController.text.isEmpty ? null : _allergyController.text,
              );
              widget.onProfileAdded(profile);
              Navigator.of(context).pop();
            }
          },
          child: const Text('추가'),
        ),
      ],
    );
  }

  // 공통 입력 필드 위젯
  Widget _textField(TextEditingController controller, String label, String hint,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPurple)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textPurple.withOpacity(0.6)),
            filled: true,
            fillColor: AppTheme.lightPink,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
          ),
          style: const TextStyle(color: AppTheme.textPurple),
          validator: (value) => value == null || value.isEmpty ? '$label을 입력해주세요.' : null,
        ),
      ],
    );
  }
}
