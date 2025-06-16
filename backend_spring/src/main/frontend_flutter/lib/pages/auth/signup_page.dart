import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../../screens/auth/address_search/address_search_page.dart';
import '../../screens/auth/signup_page_ui.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender;
  File? _selectedImage;

  // 이미지 선택 함수
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 회원가입 API 요청
  Future<bool> signup(File? imageFile) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/member/register');

    final Map<String, dynamic> memberData = {
      'username': _emailController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'nickname': _nicknameController.text,
      'phoneNumber': _phoneController.text,
      'address': _addressController.text,
      'birth': _birthDateController.text,
      'gender': _selectedGender == '남성' ? 'M' : 'F',
    };

    final request = http.MultipartRequest('POST', url);
    request.fields['memberData'] = jsonEncode(memberData);

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('회원가입 실패: ${response.statusCode}');
        debugPrint('응답 내용: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('예외 발생: $e');
      return false;
    }
  }

  // 회원가입 버튼 클릭 시 실행
  void _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('비밀번호가 일치하지 않습니다.');
      return;
    }

    final success = await signup(_selectedImage);
    _showSnackBar(success ? '회원가입 성공!' : '회원가입 실패');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _checkNicknameDuplicate() {
    debugPrint('닉네임 중복 확인: ${_nicknameController.text}');
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryPurple,
            onPrimary: Colors.white,
            onSurface: AppTheme.textPurple,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryPurple),
          ),
          textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Jua'),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      _birthDateController.text =
      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _searchAddress() async {
    final selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressSearchPage()),
    );

    if (selectedAddress != null) {
      setState(() {
        _addressController.text = selectedAddress;
      });
    }
  }


  void _handleGenderChanged(String? gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPurple),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SignupPageUI(
        emailController: _emailController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        nicknameController: _nicknameController,
        nameController: _nameController,
        phoneController: _phoneController,
        birthDateController: _birthDateController,
        addressController: _addressController,
        selectedGender: _selectedGender,
        onSignup: _signup,
        onDuplicateNicknameCheck: _checkNicknameDuplicate,
        onSelectDate: _selectDate,
        onGenderChanged: _handleGenderChanged,
        onAddressSearch: _searchAddress,
        onPickImage: pickImage, // 이미지 선택 가능
        selectedImage: _selectedImage, // 선택된 이미지 넘기기
      ),
    );
  }
}
