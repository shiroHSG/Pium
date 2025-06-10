import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:frontend_flutter/pages/my_page/babyProfile_edit_page.dart';
import 'package:frontend_flutter/screens/my_page/babyProfile_ui.dart';

class BabyProfilePage extends StatefulWidget {
  const BabyProfilePage({Key? key}) : super(key: key);

  @override
  State<BabyProfilePage> createState() => _BabyProfilePageState();
}

class _BabyProfilePageState extends State<BabyProfilePage> {
  final List<BabyProfile> _babyProfiles = [];

  @override
  void initState() {
    super.initState();
    _loadDummyProfiles();
  }

  // 더미 데이터 로드 (테스트용)
  Future<void> _loadDummyProfiles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _babyProfiles.addAll([
        BabyProfile(
          name: '김철수',
          dob: '2018.03.20',
          gender: '남아',
          height: '110cm',
          weight: '18kg',
          allergies: '없음',
        ),
        BabyProfile(
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

  // 수정 페이지로 이동 후 결과 반영
  Future<void> _navigateToEditProfile(BabyProfile baby) async {
    final updated = await Navigator.push<BabyProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => BabyProfileEditPage(babyProfile: baby),
      ),
    );

    if (updated != null) {
      setState(() {
        final idx = _babyProfiles.indexOf(baby);
        if (idx != -1) _babyProfiles[idx] = updated;
      });
      _showSnack('아이 프로필이 성공적으로 수정되었습니다!');
    }
  }

  // 프로필 추가
  void _addBabyProfile(BabyProfile newProfile) {
    setState(() {
      _babyProfiles.add(newProfile);
    });
    _showSnack('새 아이 프로필이 추가되었습니다!');
  }

  // 프로필 추가 다이얼로그 표시
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => _AddBabyProfileDialog(onProfileAdded: _addBabyProfile),
    );
  }

  // UI
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
        onAdd: _showAddDialog, // 직접 메서드 참조
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }
}

// _AddBabyProfileDialog 위젯을 BabyProfilePage 클래스 외부에 정의합니다.
class _AddBabyProfileDialog extends StatefulWidget {
  final Function(BabyProfile) onProfileAdded;

  const _AddBabyProfileDialog({required this.onProfileAdded});

  @override
  State<_AddBabyProfileDialog> createState() => _AddBabyProfileDialogState();
}

class _AddBabyProfileDialogState extends State<_AddBabyProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  String? _dateValidator(String? v) {
    if (v == null || v.isEmpty) return '생년월일을 입력해주세요.';
    if (!RegExp(r'^\d{4}\.\d{2}\.\d{2}$').hasMatch(v)) return 'YYYY.MM.DD 형식으로 입력하세요.';
    return null;
  }

  Widget _inputField(
      TextEditingController ctrl,
      String label, {
        String? hint,
        String? bottomHint,
        TextInputType keyboard = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPurple)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          inputFormatters: inputFormatters,
          validator: validator,
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
        ),
        if (bottomHint != null) ...[
          const SizedBox(height: 4),
          Text(bottomHint, style: const TextStyle(fontSize: 12, color: AppTheme.textPurple)),
        ],
      ],
    );
  }

  Widget _genderPicker(StateSetter setDialogState) {
    Widget genderBtn(String value) => Expanded(
      child: GestureDetector(
        onTap: () => setDialogState(() => _selectedGender = value),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: _selectedGender == value ? AppTheme.primaryPurple : AppTheme.lightPink,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _selectedGender == value ? AppTheme.primaryPurple : Colors.transparent,
              width: _selectedGender == value ? 2 : 0,
            ),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: _selectedGender == value ? Colors.white : AppTheme.textPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('성별',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPurple)),
        const SizedBox(height: 6),
        Row(children: [genderBtn('남아'), const SizedBox(width: 10), genderBtn('여아')]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('새 아이 정보 추가'),
      content: StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _inputField(_nameController, '이름', hint: '아이 이름'),
                const SizedBox(height: 15),
                _inputField(_dobController, '생년월일',
                    hint: 'YYYY.MM.DD',
                    keyboard: TextInputType.datetime,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    validator: _dateValidator),
                const SizedBox(height: 15),
                _genderPicker(setState),
                const SizedBox(height: 15),
                _inputField(_heightController, '키',
                    hint: '예: 100cm',
                    keyboard: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                const SizedBox(height: 15),
                _inputField(_weightController, '몸무게',
                    hint: '예: 15kg',
                    keyboard: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                const SizedBox(height: 15),
                _inputField(_allergiesController, '알러지',
                    hint: '예: 우유, 땅콩', bottomHint: '없으면 "없음"으로 입력하세요.'),
              ],
            ),
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
            if (_formKey.currentState!.validate()) {
              final newProfile = BabyProfile(
                name: _nameController.text,
                dob: _dobController.text,
                gender: _selectedGender,
                height: _heightController.text.isEmpty ? null : _heightController.text,
                weight: _weightController.text.isEmpty ? null : _weightController.text,
                allergies: _allergiesController.text.isEmpty ? null : _allergiesController.text,
              );
              widget.onProfileAdded(newProfile);
              Navigator.of(context).pop();
            }
          },
          child: const Text('추가'),
        ),
      ],
    );
  }
}