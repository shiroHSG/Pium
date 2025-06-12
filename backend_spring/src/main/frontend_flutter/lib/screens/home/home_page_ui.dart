import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:frontend_flutter/models/calendar/schedule.dart';

class BabyProfileHeader extends StatelessWidget {
  final BabyProfile babyProfile;
  final ImageProvider? babyImage;
  final VoidCallback onEditPressed;

  const BabyProfileHeader({
    Key? key,
    required this.babyProfile,
    this.babyImage,
    required this.onEditPressed,
  }) : super(key: key);

  String genderToKorean(Gender? gender) {
    if (gender == null) return '성별 정보 없음';
    return gender == Gender.MALE ? '남자' : '여자';
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onEditPressed,
      child: Container(
        width: screenWidth,
        height: 250,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        decoration: const BoxDecoration(
          color: AppTheme.lightPink,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple,
                    shape: BoxShape.circle,
                    image: babyImage != null
                        ? DecorationImage(image: babyImage!, fit: BoxFit.cover)
                        : null,
                  ),
                  child: babyImage == null
                      ? const Center(
                    child: Text(
                      '아이\n사진',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      babyProfile.name,
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppTheme.textPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDate(babyProfile.birthDate)} / '
                          '${babyProfile.height?.toStringAsFixed(1) ?? '??'} cm / '
                          '${babyProfile.weight?.toStringAsFixed(1) ?? '??'} kg',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      genderToKorean(babyProfile.gender),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  babyProfile.developmentStep ?? '성장 발달 내용이 없습니다.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
