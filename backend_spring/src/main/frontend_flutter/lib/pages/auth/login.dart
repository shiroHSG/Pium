import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/pages/auth/signup_page.dart';
import 'package:frontend_flutter/pages/home/home_page.dart';
import 'login_ui.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _idController = TextEditingController(); // 아이디 (이메일, 닉네임 등) 입력
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    _loadCredentials();  // 앱 시작 시 저장되어있는 아이디와 비밀번호를 불러오는 함수 호출
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

    final String apiUrl = 'http://localhost:8080/auth/login'; // API

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _idController.text, // 백엔드의 실제 아이디 필드명
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);  // JSON 형식 응답 -> Map 객체로 변환, responseData는 Map 객체 담는중
        final String? authToken = responseData['token']; // responseData 맵에서 토큰 키 찾아서 authToken 변수에 저장
        final Map<String, dynamic>? userData = responseData['user']; // responseData 맵에서 user 라는 키에 해당하는 사용자 정보를 추출해 userData에 저장

        if (authToken != null) {
          await _storage.write(key: 'authToken', value: authToken);
          await _saveCredentials();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인에 실패했습니다. 서버 응답에 토큰이 없습니다.')),
          );
        }
      } else {
        final Map<String, dynamic>? errorData = jsonDecode(response.body);
        final String errorMessage = errorData?['message'] ?? '로그인에 실패했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
      );
      print('로그인 오류: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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