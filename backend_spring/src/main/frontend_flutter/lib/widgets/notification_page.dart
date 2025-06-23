import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String selectedCategory = '전체';
  final List<String> categories = ['전체', '커뮤니티', '나눔 품앗이', '채팅'];

  final List<Map<String, dynamic>> allNotifications = [
    {
      'category': '커뮤니티',
      'icon': Icons.groups,
      'message': '커뮤니티 페이지 알림입니다.',
      'date': '알림 온 날짜 시간',
    },
    {
      'category': '채팅',
      'icon': Icons.chat,
      'message': '채팅 페이지 알림입니다.',
      'date': '2025.06.23 13:00',
    },
  ];

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
          const SizedBox(height: 50),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      cat,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
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
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final notification = filtered[index];
                return ListTile(
                  leading: Icon(notification['icon'], color: AppTheme.textPurple),
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
