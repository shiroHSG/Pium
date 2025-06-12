import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:intl/intl.dart';
import '../../screens/my_page/babyProfile_edit_page_ui.dart';

class BabyProfileEditPage extends StatefulWidget {
  final BabyProfile babyProfile;

  const BabyProfileEditPage({Key? key, required this.babyProfile}) : super(key: key);

  @override
  State<BabyProfileEditPage> createState() => _BabyProfileEditPageState();
}

class _BabyProfileEditPageState extends State<BabyProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _allergyController;
  late DateTime _selectedDate;
  Gender? _selectedGender; // ✅ nullable 처리

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.babyProfile.name);
    _selectedDate = widget.babyProfile.birthDate;
    _selectedGender = widget.babyProfile.gender; // nullable
    _heightController = TextEditingController(
        text: widget.babyProfile.height?.toStringAsFixed(1) ?? '');
    _weightController = TextEditingController(
        text: widget.babyProfile.weight?.toStringAsFixed(1) ?? '');
    _allergyController = TextEditingController(
        text: widget.babyProfile.allergy ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  void _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updated = widget.babyProfile.copyWith(
        name: _nameController.text,
        birthDate: _selectedDate,
        gender: _selectedGender, // nullable 그대로 넘김
        height: _heightController.text.isEmpty
            ? null
            : double.tryParse(_heightController.text),
        weight: _weightController.text.isEmpty
            ? null
            : double.tryParse(_weightController.text),
        allergy: _allergyController.text.isEmpty ? null : _allergyController.text,
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '아이정보 수정 페이지',
          style: TextStyle(
            color: AppTheme.textPurple,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
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
                EditInputField(
                  controller: _nameController,
                  labelText: '이름',
                  validator: (v) =>
                  v == null || v.isEmpty ? '이름을 입력해주세요.' : null,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickBirthDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 15),
                    decoration: BoxDecoration(
                      color: AppTheme.lightPink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      DateFormat('yyyy.MM.dd').format(_selectedDate),
                      style: const TextStyle(
                          fontSize: 16, color: AppTheme.textPurple),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GenderSelectionForEdit(
                  selectedGender: _selectedGender?.name ?? '', // ✅ null safe
                  onChanged: (genderStr) {
                    setState(() {
                      _selectedGender = genderStr == '남아'
                          ? Gender.MALE
                          : Gender.FEMALE;
                    });
                  },
                ),
                const SizedBox(height: 20),
                EditInputField(
                  controller: _heightController,
                  labelText: '키',
                  hintText: '예: 110',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 20),
                EditInputField(
                  controller: _weightController,
                  labelText: '몸무게',
                  hintText: '예: 18',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 20),
                EditInputField(
                  controller: _allergyController,
                  labelText: '알러지',
                  hintText: '없으면 "없음"',
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveProfile,
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
}
