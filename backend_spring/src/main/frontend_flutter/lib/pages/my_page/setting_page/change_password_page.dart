import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter/models/auth/auth_services.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<http.Response> patchJson(
    Uri url, {
      Map<String, String>? headers,
      required Map<String, dynamic> body,
    }) async {
  return await http.patch(
    url,
    headers: headers,
    body: jsonEncode(body),
  );
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPw = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    // 1. 새 비밀번호와 확인이 일치하는지 확인
    if (newPw != confirm) {
      _showErrorDialog('새 비밀번호와 비밀번호 확인이 일치하지 않습니다.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. accessToken 읽기
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      // 3. PATCH 요청 (여기서 patchJson 함수 사용!)
      final url = Uri.parse('http://10.0.2.2:8080/api/member/change_password');
      final response = await patchJson(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: {
          'currentPassword': current,
          'newPassword': newPw,
        },
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // 4. 성공
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('변경 완료'),
            content: const Text('비밀번호가 성공적으로 변경되었습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // 다이얼로그 닫기
                child: const Text('확인'),
              ),
            ],
          ),
        );
        Navigator.of(context).pop(); // 환경설정 페이지로 복귀
      } else {
        // 5. 실패
        final msg = response.body.isNotEmpty ? _parseErrorMsg(response.body) : '비밀번호 변경 실패';
        _showErrorDialog(msg);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('네트워크 오류 또는 알 수 없는 에러가 발생했습니다.');
    }
  }

  String _parseErrorMsg(String body) {
    try {
      final decoded = body.contains('{') ? (body.startsWith('{') ? body : body.substring(body.indexOf('{'))) : body;
      final Map<String, dynamic> map = decoded.isNotEmpty ? Map<String, dynamic>.from(jsonDecode(decoded)) : {};
      return map['message']?.toString() ?? '비밀번호 변경 실패';
    } catch (_) {
      return '비밀번호 변경 실패';
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        title: const Text('비밀번호 변경', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(_currentPasswordController, '현재 비밀번호'),
              const SizedBox(height: 18),
              _buildPasswordField(_newPasswordController, '새 비밀번호'),
              const SizedBox(height: 18),
              _buildPasswordField(_confirmPasswordController, '새 비밀번호 확인'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                      : const Text('변경', style: TextStyle(fontSize: 17)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        fillColor: AppTheme.lightPink,
        filled: true,
      ),
    );
  }
}
