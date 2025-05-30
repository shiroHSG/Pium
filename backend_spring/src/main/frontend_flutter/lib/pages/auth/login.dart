import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/pages/auth/signup_page.dart';
import 'package:frontend_flutter/pages/home/home_page.dart';
import 'package:frontend_flutter/models/member.dart'; // Member 모델 임포트
import '../../services/member_services.dart';
import 'login_ui.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  final _memberService = MemberService(baseUrl: 'http://10.0.2.2:8080/api/member'); // MemberService 객체 생성

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final storedId = await _storage.read(key: 'id');
    final storedPassword = await _storage.read(key: 'password');
    if (storedId != null) {
      setState(() {
        _idController.text = storedId;
      });
    }
    if (storedPassword != null) {
      setState(() {
        _passwordController.text = storedPassword;
      });
    }
  }

  Future<void> _saveCredentials() async {
    await _storage.write(key: 'id', value: _idController.text);
    await _storage.write(key: 'password', value: _passwordController.text);
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    String email = _idController.text;
    String password = _passwordController.text;

    String? authToken = await _memberService.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (authToken != null) {
      // 로그인 성공, 토큰 저장 및 홈 화면 이동
      await _storage.write(key: 'authToken', value: authToken);
      await _saveCredentials();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } else {
      // 로그인 실패 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인에 실패했습니다. 이메일 또는 비밀번호를 확인해주세요.')),
      );
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  void _findId() {
    print('아이디 찾기');
    // 아이디 찾기 로직 구현
  }

  void _findPassword() {
    print('비밀번호 찾기');
    // 비밀번호 찾기 로직 구현
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LoginUI(
        idController: _idController,
        passwordController: _passwordController,
        onLoginPressed: _login,
        onSignupPressed: _navigateToSignup,
        onFindIdPressed: _findId,
        onFindPasswordPressed: _findPassword,
      ),
    );
  }
}