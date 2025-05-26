import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            decoration: const BoxDecoration(
              color: AppTheme.lightPink,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '프로필\n사진',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '아이디',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPurple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              childAspectRatio: 1.4,
              children: [
                _buildMyPageButton(
                  context,
                  icon: Icons.person_outline,
                  label: '프로필 수정',
                  iconSize: 30,
                  textSize: 14,
                  onTap: () {
                    print('프로필 수정');
                  },
                ),
                _buildMyPageButton(
                  context,
                  icon: Icons.child_care_outlined,
                  label: '아이 정보 수정',
                  iconSize: 30,
                  textSize: 14,
                  onTap: () {
                    print('아이 정보 수정');
                  },
                ),
                _buildMyPageButton(
                  context,
                  icon: Icons.thumb_up_alt_outlined,
                  label: '내 활동',
                  iconSize: 30,
                  textSize: 14,
                  onTap: () {
                    print('내 활동');
                  },
                ),
                _buildMyPageButton(
                  context,
                  icon: Icons.settings_outlined,
                  label: '설정',
                  iconSize: 30,
                  textSize: 14,
                  onTap: () {
                    print('설정');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMyPageButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double iconSize = 30,
    double textSize = 14,
  }) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2,
          padding: EdgeInsets.zero,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
