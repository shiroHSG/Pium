// lib/pages/login.dart

import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/pages/signup_page.dart';
import 'package:frontend_flutter/main.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    print('아이디: ${_idController.text}');
    print('비밀번호: ${_passwordController.text}');

    // 어떤 아이디/비밀번호를 입력하든 메인 페이지로 이동 (MyHomePage)
    // Navigator.pushReplacement를 사용하여 뒤로가기 버튼으로 로그인 페이지로 돌아오지 않도록 함
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
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
          onPressed: () {
            // 현재 로그인 페이지가 앱의 시작 페이지라면, pop이 작동하지 않을 수 있습니다.
            // 필요에 따라 앱 종료 로직 (예: SystemNavigator.pop())을 고려할 수 있습니다.
            // 하지만 로그인 페이지가 스택의 최하단이 아닌 경우에만 pop이 유효합니다.
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/logo1.png', // 로고 이미지 경로
                width: 150,
              ),
              const SizedBox(height: 50),
              _buildInputField('아이디', _idController, false),
              const SizedBox(height: 20),
              _buildInputField('비밀번호', _passwordController, true),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _login, // _login 함수 호출
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Jua',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '계정이 없으신가요?',
                    style: TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupPage()),
                      );
                    },
                    child: const Text(
                      'sign up',
                      style: TextStyle(
                        color: AppTheme.textPurple,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Jua',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      print('아이디 찾기');
                    },
                    child: const Text(
                      '아이디찾기',
                      style: TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua'),
                    ),
                  ),
                  const Text(' | ', style: TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua')),
                  TextButton(
                    onPressed: () {
                      print('비밀번호 찾기');
                    },
                    child: const Text(
                      '비밀번호 찾기',
                      style: TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String labelText, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPurple,
            fontFamily: 'Jua',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightPink,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
            style: const TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua'),
          ),
        ),
      ],
    );
  }
}