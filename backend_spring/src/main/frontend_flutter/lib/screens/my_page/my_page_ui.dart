import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/pages/my_page/baby_profile/babyProfile_page.dart';
import 'package:frontend_flutter/pages/my_page/my_activity/my_activity_page.dart';
import 'package:frontend_flutter/pages/my_page/profile_edit/profile_edit_page.dart';
import 'package:frontend_flutter/pages/my_page/setting_page/setting_page.dart';

import '../../widgets/protected_image.dart';
import '../../widgets/s3_image.dart';

class MyPageUI extends StatelessWidget {
  final String nickname;
  final String? profileImageUrl;
  final VoidCallback onProfileUpdated;

  const MyPageUI({
    Key? key,
    required this.nickname,
    required this.profileImageUrl,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _MyPageHeader(nickname: nickname, profileImageUrl: profileImageUrl),
            const SizedBox(height: 60),
            _MyPageButtonsGrid(onProfileUpdated: onProfileUpdated),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _MyPageHeader extends StatelessWidget {
  final String nickname;
  final String? profileImageUrl;

  const _MyPageHeader({
    Key? key,
    required this.nickname,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: const BoxDecoration(
        color: AppTheme.lightPink,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? ClipOval(
              child: SizedBox(
                width: 120,
                height: 120,
                child: S3Image(
                  imageUrl: profileImageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            )
                : const CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primaryPurple,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Text(
                nickname,
                style: const TextStyle(
                  fontSize: 24,
                  color: AppTheme.textPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPageButtonsGrid extends StatelessWidget {
  final VoidCallback onProfileUpdated;

  const _MyPageButtonsGrid({required this.onProfileUpdated});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            label: '프로필',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileEditPage()),
              );
              if (result == 'updated') {
                await Future.delayed(const Duration(milliseconds: 100));
                if (context.mounted) onProfileUpdated();
              }
            },
          ),
          _buildMyPageButton(
            context,
            icon: Icons.child_care_outlined,
            label: '아이 추가 및 정보 수정',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BabyProfilePage()));
            },
          ),
          _buildMyPageButton(
            context,
            icon: Icons.thumb_up_alt_outlined,
            label: '내 활동',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyActivityPage()));
            },
          ),
          _buildMyPageButton(
            context,
            icon: Icons.settings_outlined,
            label: '환경설정',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMyPageButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        double iconSize = 30,
        double textSize = 14,
      }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 2,
        padding: EdgeInsets.zero,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
