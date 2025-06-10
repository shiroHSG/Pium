import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/auth/signup_page.dart';

import '../../models/auth/auth_services.dart';
import '../../screens/auth/login_ui.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

    setState(() {
      _isLoading = true;
    });

    bool success = await AuthService().login(
      _idController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showErrorDialog('로그인 실패', '이메일 또는 비밀번호를 확인하세요.');
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

  void _signup() {
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
        child: _isLoading
            ? CircularProgressIndicator()
            : LoginUI(
          idController: _idController,
          passwordController: _passwordController,
          onLoginPressed: _login,
          onSignupPressed: _signup,
          onFindIdPressed: _findId,
          onFindPasswordPressed: _findPassword,
          formKey: _formKey,
        ),
      ),
    );
  }
}