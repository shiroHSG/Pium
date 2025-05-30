import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/auth/signup_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/auth/login_ui.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _idController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final token = response.body;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog('로그인 실패', '이메일 또는 비밀번호를 확인하세요.');
      }
    } catch (e) {
      _showErrorDialog('오류 발생', '로그인 처리 중 오류가 발생했습니다.');
      print('로그인 오류: $e');
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text('확인'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _Signup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
    );
  }

  void _findId() {
    Navigator.pushNamed(context, '/findId');
  }

  void _findPassword() {
    Navigator.pushNamed(context, '/findPassword');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoginUI( // LoginUI 위젯 사용
          idController: _idController,
          passwordController: _passwordController,
          onLoginPressed: _login,
          onSignupPressed: _Signup,
          onFindIdPressed: _findId,
          onFindPasswordPressed: _findPassword,
        ),
      ),
    );
  }
}