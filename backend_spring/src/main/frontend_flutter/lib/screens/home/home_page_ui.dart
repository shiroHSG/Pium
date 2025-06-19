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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        babyProfile.name,
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppTheme.textPurple,
                        ),
                        overflow: TextOverflow.ellipsis, // ✅ 너무 긴 텍스트 방지
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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

class TodayScheduleCard extends StatefulWidget {
  final List<Schedule> todaySchedules; // 전체 일정
  final VoidCallback onCalendarTap;

  const TodayScheduleCard({
    Key? key,
    required this.todaySchedules,
    required this.onCalendarTap,
  }) : super(key: key);

  @override
  State<TodayScheduleCard> createState() => _TodayScheduleCardState();
}

class _TodayScheduleCardState extends State<TodayScheduleCard> {
  DateTime currentDate = DateTime.now();

  void _goToPreviousDay() {
    setState(() {
      currentDate = currentDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      currentDate = currentDate.add(const Duration(days: 1));
    });
  }

  List<Schedule> get filteredSchedules {
    return widget.todaySchedules.where((schedule) =>
    schedule.startTime.year == currentDate.year &&
        schedule.startTime.month == currentDate.month &&
        schedule.startTime.day == currentDate.day
    ).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime)); // 시간순 정렬
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(currentDate, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: GestureDetector(
        onTap: widget.onCalendarTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
            decoration: BoxDecoration(
              color: AppTheme.lightPink,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                // 왼쪽 화살표
                SizedBox(
                  width: 40, height: 60,
                  child: InkWell(
                    onTap: _goToPreviousDay,
                    borderRadius: BorderRadius.circular(8),
                    child: const Center(
                      child: Icon(Icons.arrow_back_ios, color: Colors.grey, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('M월 d일 (E)', 'ko').format(currentDate),
                        style: const TextStyle(
                          color: AppTheme.textPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (filteredSchedules.isEmpty)
                        const Text(
                          '일정이 없습니다.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ...filteredSchedules.map((schedule) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(int.parse(
                                  'FF${schedule.colorTag.replaceAll('#', '')}',
                                  radix: 16,
                                )),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${schedule.title} - ${DateFormat('a h:mm', 'ko').format(schedule.startTime)}',
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
                // 오른쪽 화살표
                SizedBox(
                  width: 40, height: 60,
                  child: InkWell(
                    onTap: _goToNextDay,
                    borderRadius: BorderRadius.circular(8),
                    child: const Center(
                      child: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
                    ),
                  ),
                ),
              ],
            ),
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
        const SizedBox(height: 30),
      ],
    );
  }
}

