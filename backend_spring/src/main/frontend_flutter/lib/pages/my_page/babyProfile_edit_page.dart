import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
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
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _allergiesController;

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.babyProfile.name);
    _dobController = TextEditingController(text: widget.babyProfile.dob);
    _heightController = TextEditingController(text: widget.babyProfile.height ?? '');
    _weightController = TextEditingController(text: widget.babyProfile.weight ?? '');
    _allergiesController = TextEditingController(text: widget.babyProfile.allergies ?? '');
    _selectedGender = widget.babyProfile.gender;
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
      final updated = widget.babyProfile.copyWith(
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                EditInputField(
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
                GenderSelectionForEdit(
                  selectedGender: _selectedGender,
                  onChanged: (gender) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                ),
                const SizedBox(height: 20),
                EditInputField(
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
                EditInputField(
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
                EditInputField(
                  controller: _allergiesController,
                  labelText: '알러지',
                  hintText: '예: 우유, 땅콩',
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