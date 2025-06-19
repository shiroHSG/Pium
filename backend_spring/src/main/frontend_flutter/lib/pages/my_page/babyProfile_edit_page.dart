import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:intl/intl.dart';
import '../../models/child/child_api.dart';
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
  Gender? _selectedGender;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.babyProfile.name);
    _selectedDate = widget.babyProfile.birthDate;
    _selectedGender = widget.babyProfile.gender;
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // 수정된 정보를 객체에 반영 (profileImgUrl은 서버에서 처리하므로 null로 유지)
      final updated = widget.babyProfile.copyWith(
        name: _nameController.text,
        birthDate: _selectedDate,
        gender: _selectedGender,
        height: _heightController.text.isEmpty
            ? null
            : double.tryParse(_heightController.text),
        weight: _weightController.text.isEmpty
            ? null
            : double.tryParse(_weightController.text),
        allergy: _allergyController.text.isEmpty ? null : _allergyController.text,
        profileImageUrl: null, // ⚠️ 서버에서 처리하므로 직접 보내지 않음
      );

      // API 호출
      final success = await ChildApi.updateMyChild(
        updated,
        imagePath: _selectedImage?.path,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, updated); // 수정 완료 후 이전 화면으로
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('수정 완료!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('수정 실패'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final imageProvider = _selectedImage != null
        ? FileImage(_selectedImage!)
        : (widget.babyProfile.profileImageUrl != null
        ? NetworkImage('http://10.0.2.2:8080${widget.babyProfile.profileImageUrl!}')
        : const AssetImage('assets/default_baby.png') as ImageProvider);

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
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: AppTheme.primaryPurple,
                    backgroundImage: imageProvider is ImageProvider ? imageProvider : null,
                    child: imageProvider == null
                        ? const Icon(Icons.add_a_photo, color: Colors.white, size: 50)
                        : null,
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
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                    decoration: BoxDecoration(
                      color: AppTheme.lightPink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      DateFormat('yyyy.MM.dd').format(_selectedDate),
                      style: const TextStyle(fontSize: 16, color: AppTheme.textPurple),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GenderSelectionForEdit(
                  selectedGender: _selectedGender?.name ?? '',
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),
                EditInputField(
                  controller: _weightController,
                  labelText: '몸무게',
                  hintText: '예: 18',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('삭제하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('정말 삭제하시겠어요?'),
                        content: const Text('삭제된 아이 정보는 복구할 수 없습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final success = await ChildApi.deleteChild(widget.babyProfile.childId!);
                      if (context.mounted) {
                        Navigator.pop(context, 'deleted');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? '삭제 완료!' : '삭제 실패'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
