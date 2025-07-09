import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class ProtectedImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;

  const ProtectedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain, // 기본값: 게시판용
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
      setState(() => isLoading = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      print('❌ 토큰 없음 → 요청 중단');
      setState(() => isLoading = false);
      return;
    }

    final fullUrl = widget.imageUrl;

    try {
      final uri = Uri.parse(fullUrl);
      final isS3 = uri.host.contains('s3.') || uri.host.contains('amazonaws.com');

      final response = await http.get(
        uri,
        headers: isS3
            ? {} // ✅ S3는 헤더 없이 요청
            : {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          imageBytes = response.bodyBytes;
          isLoading = false;
        });
      } else {
        print('❌ 이미지 로드 실패 - 응답 본문: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('🔥 이미지 요청 예외 발생: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (imageBytes == null) {
      return const Center(
        child: Text(
          '이미지 없음',
          style: TextStyle(fontSize: 14, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Image.memory(
      imageBytes!,
      fit: widget.fit,
      key: ValueKey(widget.imageUrl),
    );
  }
}
