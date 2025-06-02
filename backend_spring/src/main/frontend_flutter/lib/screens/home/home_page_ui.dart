import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/schedule.dart';
import 'package:frontend_flutter/pages/calendar_page/calendar_page.dart';

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
                    Text(
                      '${babyProfile.dob} / ${babyProfile.height ?? '??'} cm / ${babyProfile.weight ?? '??'} kg',
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
                  babyProfile.development ?? '성장 발달 내용이 없습니다.',
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

class TodayScheduleCard extends StatelessWidget {
  final List<Schedule> todaySchedules;
  final VoidCallback onCalendarTap;

  const TodayScheduleCard({
    Key? key,
    required this.todaySchedules,
    required this.onCalendarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: GestureDetector(
        onTap: onCalendarTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
          decoration: BoxDecoration(
            color: AppTheme.lightPink,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios, color: Colors.grey[600], size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${today.day}일',
                      style: const TextStyle(
                        color: AppTheme.textPurple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (todaySchedules.isEmpty)
                      const Text(
                        '오늘 일정이 없습니다.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ...todaySchedules.map((schedule) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: schedule.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${schedule.title} - ${schedule.time}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class PopularPostsSection extends StatelessWidget {
  const PopularPostsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        const SizedBox(height: 40),
        Row(
          children: [
            const SizedBox(width: 16),
            const Expanded(
              child: Divider(color: AppTheme.textPurple, thickness: 1),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              child: Text(
                '인기 게시글',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
              child: Divider(color: AppTheme.textPurple, thickness: 1),
            ),
            const SizedBox(width: 16),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            width: screenWidth - (16.0 * 2),
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Center(child: Text('인기 게시글 내용 들어갈 자리')),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.arrow_forward_ios, color: AppTheme.textPurple),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}