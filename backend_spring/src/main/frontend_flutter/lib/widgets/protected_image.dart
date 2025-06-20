import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class ProtectedImage extends StatefulWidget {
  final String imageUrl;
  final double size;

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

  @override
  void didUpdateWidget(covariant ProtectedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        imageBytes = null;
        isLoading = true;
      });
      _loadImage();
    }
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
              ? Image.memory(
            imageBytes!,
            fit: BoxFit.cover,
            key: ValueKey(widget.imageUrl), // 이미지 URL 변경 시 리렌더링
          )
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
