import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class MyActivityPage extends StatelessWidget {
  const MyActivityPage({super.key});

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPurple,
        ),
      ),
    );
  }

  Widget _buildActivityButton(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.lightPink,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPurple,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        elevation: 0,
        title: const Text('내 활동', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: ListView(
          children: [
            // 커뮤니티 섹션
            _buildSectionTitle('커뮤니티'),
            _buildActivityButton('작성한 게시글', () {
              print('작성한 게시글');
            }),
            _buildActivityButton('좋아요한 글', () {
              print('좋아요한 글');
            }),

            // 나눔 품앗이 섹션
            _buildSectionTitle('나눔 품앗이'),
            _buildActivityButton('나눔 좋아요 누른 글', () {
              print('나눔 좋아요 누른 글');
            }),
            _buildActivityButton('품앗이 좋아요 누른 글', () {
              print('품앗이 좋아요 누른 글');
            }),
            _buildActivityButton('작성한 글', () {
              print('작성한 품앗이 글');
            }),

            // 기타
            _buildSectionTitle('기타'),
            _buildActivityButton('최근 본 글', () {
              print('최근 본 글');
            }),
          ],
        ),
      ),
    );
  }
}
