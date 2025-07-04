import 'package:flutter/material.dart';
import 'package:frontend_flutter/widgets/protected_image.dart';

class FullscreenImage extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;

  const FullscreenImage({
    Key? key,
    required this.imageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 전체화면 이미지 뷰
        GestureDetector(
          onTap: onTap ?? () => Navigator.pop(context), // 기본 동작도 지정 가능
          child: Center(
            child: InteractiveViewer(
              child: ProtectedImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        // 닫기 버튼 (X)
        Positioned(
          top: 40,
          right: 20,
          child: GestureDetector(
            onTap: onTap ?? () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
