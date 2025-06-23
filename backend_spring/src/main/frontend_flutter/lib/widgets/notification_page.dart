import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification/notification.dart';
import '../theme/app_theme.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String selectedCategory = '전체';
  final List<String> categories = ['전체', '커뮤니티', '나눔 품앗이', '메이트 요청'];
  List<Map<String, dynamic>> allNotifications = [];

  @override
  void initState() {
    super.initState();

    _loadUnreadNotifications();

    // 🔔 전역 콜백 등록 → 알림 수신 시 UI 갱신
    onNotificationUpdate = () {
      setState(() {
        allNotifications = List.from(notificationList);
      });
    };
  }

  // 첫 알림 호출
  Future<void> _loadUnreadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token != null) {
      await fetchUnreadNotifications(token);
      setState(() {
        allNotifications = List.from(notificationList);
      });
    }
  }

  @override
  void dispose() {
    // 🔕 페이지 나가면 콜백 해제
    onNotificationUpdate = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == '전체'
        ? allNotifications
        : allNotifications
        .where((n) => n['category'] == selectedCategory)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '알림',
          style: TextStyle(color: AppTheme.textPurple),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPurple),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ✅ 카테고리 + 읽음 처리 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf8cde2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        items: categories
                            .map((cat) => DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat,
                              style: const TextStyle(fontSize: 16)),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        icon: const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('accessToken');
                    if (token != null) {
                      await markAllNotificationsAsRead(token);
                      setState(() {
                        notificationList.clear();
                        allNotifications.clear();
                      });
                    }
                  },
                  child: const Text(
                    '읽음 처리',
                    style: TextStyle(
                      color: AppTheme.textPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ✅ 알림 리스트
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final notification = filtered[index];
                return ListTile(
                  leading:
                  Icon(notification['icon'], color: AppTheme.textPurple),
                  title: Text(notification['message']),
                  subtitle: Text(notification['date']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
