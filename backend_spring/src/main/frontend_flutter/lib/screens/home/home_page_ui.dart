import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:frontend_flutter/models/calendar/schedule.dart';
import 'package:frontend_flutter/models/post/post_api_services.dart';
import 'package:frontend_flutter/models/post/post_response.dart';
import 'package:frontend_flutter/models/policy/policy_service.dart';
import 'package:frontend_flutter/models/policy/PolicyResponse.dart';

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

    if (babyProfile.name == '등록된 아이 없음') {
      return GestureDetector(
        onTap: onEditPressed,
        child: Container(
          width: screenWidth,
          height: 250,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: const BoxDecoration(
            color: AppTheme.lightPink,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '등록된 아이 없음',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '아이 정보를 등록해주세요.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatDate(babyProfile.birthDate)}\n'
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
                  (babyProfile.developmentStep == null || babyProfile.developmentStep!.trim().isEmpty)
                      ? '성장 발달 내용이 없습니다.'
                      : babyProfile.developmentStep!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
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
  final List<Schedule> todaySchedules;
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
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Widget build(BuildContext context) {
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

class PopularPostsSection extends StatefulWidget {
  const PopularPostsSection({Key? key}) : super(key: key);

  @override
  State<PopularPostsSection> createState() => _PopularPostsSectionState();
}

class _PopularPostsSectionState extends State<PopularPostsSection> {
  late Future<List<dynamic>> _popularItemsFuture;
  final PageController _pageController = PageController(viewportFraction: 0.95);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _popularItemsFuture = _fetchPopularItems();
  }

  Future<List<dynamic>> _fetchPopularItems() async {
    final posts = await PostApiService.fetchPopularPosts(size: 3);
    final policy = await PolicyService.fetchPopularPolicy();
    return [...posts, policy];
  }

  void _nextPage(int itemCount) {
    setState(() {
      _currentPage = (_currentPage + 1) % itemCount;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  void _onCardTap(dynamic item) {
    if (item is PostResponse) {
      Navigator.pushNamed(context, '/postDetail', arguments: item.id);
    } else if (item is PolicyResponse) {
      Navigator.pushNamed(context, '/policyDetail', arguments: item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        const SizedBox(height: 40),
        Row(
          children: [
            const SizedBox(width: 16),
            const Expanded(child: Divider(color: AppTheme.textPurple, thickness: 1)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              child: Text(
                '인기 게시글',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(child: Divider(color: AppTheme.textPurple, thickness: 1)),
            const SizedBox(width: 16),
          ],
        ),
        FutureBuilder<List<dynamic>>(
          future: _popularItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 140,
                child: Center(child: Text('인기 게시글/정책을 불러오는 데 실패했습니다')),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox(
                height: 140,
                child: Center(child: Text('인기 게시글/정책이 없습니다.')),
              );
            } else {
              final items = snapshot.data!;
              return SizedBox(
                height: 140,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: items.length,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        if (item is PostResponse) {
                          return _buildPostCard(item);
                        } else if (item is PolicyResponse) {
                          return _buildPolicyCard(item);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    Positioned(
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: AppTheme.textPurple),
                        onPressed: () => _nextPage(items.length),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildPostCard(PostResponse post) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      color: Colors.white,
      child: InkWell(
        onTap: () => _onCardTap(post),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.content,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.pink, size: 18),
                        const SizedBox(width: 2),
                        Text('${post.likeCount}'),
                        const SizedBox(width: 12),
                        Icon(Icons.comment, color: Colors.grey, size: 16),
                        const SizedBox(width: 2),
                        Text('${post.commentCount}'),
                      ],
                    )
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: AppTheme.textPurple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyCard(PolicyResponse policy) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      color: Colors.white,
      child: InkWell(
        onTap: () => _onCardTap(policy),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      policy.title ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      policy.content ?? '',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.visibility, color: Colors.blueGrey, size: 18),
                        const SizedBox(width: 2),
                        Text('${policy.viewCount ?? 0}'),
                        const SizedBox(width: 12),
                        Icon(Icons.info, color: Colors.blueGrey, size: 16),
                        const SizedBox(width: 2),
                        Text('정책'),
                      ],
                    )
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: AppTheme.textPurple),
            ],
          ),
        ),
      ),
    );
  }
}
