import 'package:flutter/material.dart';
import 'package:frontend_flutter/widgets/custom_bottom_bar.dart';
import 'package:frontend_flutter/widgets/custom_drawer.dart';
import '../../screens/policy_page/policy_detail_page_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PolicyDetailPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String target;
  final String period;
  final String content;
  final String method;
  final String link;

  const PolicyDetailPage({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.target,
    required this.period,
    required this.content,
    required this.method,
    required this.link,
  }) : super(key: key);

  @override
  State<PolicyDetailPage> createState() => _PolicyDetailPageState();
}

class _PolicyDetailPageState extends State<PolicyDetailPage> {
  int _unreadCount = 0;
  final String _baseUrl = 'http://YOUR_BACKEND_URL'; // ✅ 실제 주소로 변경

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/chatroom/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _unreadCount = int.parse(response.body);
        });
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: CustomDrawer(
        onItemSelected: (index) {},
        onLoginStatusChanged: (isLoggedIn) {},
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 3,
        onItemTapped: (index) {},
        unreadCount: _unreadCount, // ✅ 전달
      ),
      body: PolicyDetailPageUI(
        title: widget.title,
        imageUrl: widget.imageUrl,
        target: widget.target,
        period: widget.period,
        content: widget.content,
        method: widget.method,
        link: widget.link,
      ),
    );
  }
}
