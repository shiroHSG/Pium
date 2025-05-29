import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class LoginUI extends StatelessWidget {
  final TextEditingController idController;
  final TextEditingController passwordController;
  final VoidCallback onLoginPressed;
  final VoidCallback onSignupPressed;
  final VoidCallback onFindIdPressed;
  final VoidCallback onFindPasswordPressed;

  const LoginUI({
    Key? key,
    required this.idController,
    required this.passwordController,
    required this.onLoginPressed,
    required this.onSignupPressed,
    required this.onFindIdPressed,
    required this.onFindPasswordPressed,
  }) : super(key: key);

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
              fillColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Image.asset(
              'assets/logo1.png',
              width: 150,
            ),
            const SizedBox(height: 50),
            _buildInputField('아이디', idController, false),
            const SizedBox(height: 20),
            _buildInputField('비밀번호', passwordController, true),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onLoginPressed,
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
                  onPressed: onSignupPressed,
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
                  onPressed: onFindIdPressed,
                  child: const Text(
                    '아이디찾기',
                    style: TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua'),
                  ),
                ),
                const Text(' | ', style: TextStyle(color: AppTheme.textPurple, fontFamily: 'Jua')),
                TextButton(
                  onPressed: onFindPasswordPressed,
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
    );
  }
}