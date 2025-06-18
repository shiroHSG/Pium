// 이미지를 서버에서 불러와서 화면에 보여줌(JWT 토큰이 필요한 보호된 URL에서 불러옴)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class ProtectedImage extends StatefulWidget {  // ProtectedImage : 이미지를 서버에서 직접 받아와서 JWT 인증 헤더 붙여서 표시해주는 커스텀 위젯
  final String imageUrl;
  final double size; // 정사각형 이미지 크기

  const ProtectedImage({
    super.key,
    required this.imageUrl,
    this.size = 150,
  });

  @override
  State<ProtectedImage> createState() => _ProtectedImageState();
}

class _ProtectedImageState extends State<ProtectedImage> {
  Uint8List? imageBytes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    print('📦 요청 URL: ${widget.imageUrl}');

    if (widget.imageUrl.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      print('❌ 토큰 없음 → 요청 중단');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      print('🟡 이미지 요청 보냄: ${widget.imageUrl}');
      final response = await http.get(
        Uri.parse(widget.imageUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('✅ 이미지 로드 성공');
        setState(() {
          imageBytes = response.bodyBytes;
          isLoading = false;
        });
      } else {
        print('❌ 이미지 로드 실패 - 응답 본문: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('🔥 이미지 요청 예외 발생: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipOval(
        child: Container(
          color: Colors.grey[200],
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : imageBytes != null
              ? Image.memory(imageBytes!, fit: BoxFit.cover)  // 받은 바이트 플러터 이미지로 표시
              : const Center(
            child: Text(
              '이미지 없음',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
