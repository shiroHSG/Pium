import 'package:flutter/material.dart';
import 'package:frontend_flutter/widgets/custom_bottom_bar.dart';
import 'package:frontend_flutter/widgets/custom_drawer.dart';
import '../../screens/policy_page/policy_detail_page_ui.dart';

class PolicyDetailPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: CustomDrawer(
        onItemSelected: (index) {},
        onLoginStatusChanged: (isLoggedIn) {},
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 3,
        onItemTapped: (index) {},
      ),
      body: PolicyDetailPageUI(
        title: title,
        imageUrl: imageUrl,
        target: target,
        period: period,
        content: content,
        method: method,
        link: link,
      ),
    );
  }
}
